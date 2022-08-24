.data
	numero: .asciiz "\nIngrese un numero entero no negativo: "
	mensajeError: .asciiz "\nDebe ingresar un numero entero no negativo"
	mensajeResultado: .asciiz "\n\nFactorial y potencia: "
	guion: .asciiz " - "
	resultado: .asciiz "\nEl resultado de la división potencia/factorial es: "
	punto: .asciiz "."
	resultadoFinal: .asciiz "\n\nLa aproximación para la función seno \nen torno a 0, de orden 11, es: "
	resultadoPositivos: .asciiz "\n\nSuma positivos: "
	resultadoNegativos: .asciiz "\n\nSuma negativos: "
	signo: .asciiz "-"
.text
	#437 instrucciones
	#Este programa acepta un número entero hasta 7 puesto que con el número 8, al elevarlo a 11, se sale del
	#límite que soporta un registro
	li $v0, 4 #codigo 4 para imprimir un string
	la $a0, numero #se imprime un mensaje para ingresar el número
	syscall #llamada al sistema
	
	#Se obtiene el valor
	li $v0,5 #se pone v0 en 5 para recibir un entero
	syscall #llamada al sistema
	
	move $a1, $v0 #se mueve el contenido de v0 a a1
	
	bltz  $a1,error #si el valor ingresado es menor a 0, salta a la etiqueta error
	beqz $a1,salidaFinal #si el valor ingresado es 0, salta a la salida, entregando como resultado 0
	
	#En $t0 se guarda el exponente y además se calcula el factorial de este
	#Comienza en 5, ya que que la función seno hiperbólico es impar, pero el valor ingresado se suma al final
	addi $t0,$zero,5
	#Se crea una copia de $t0 en $t1, ya que se va modificando
	add $t1,$zero,$t0
	
	#se hace el llamado a la subrutina
	jal seno
	
	seno:
		#si el iterador que representa el exponente y el n de factorial es mayor que 11, se sale de la subrutina
		#saltando a la subrutina que muestra el resultado final de la aproximación
		bgt $t0,9,salida 
	
		factorial:
			#Aqui se obtiene el factorial de $t0
			#El factorial se guarda en s3
				
			#t1 es una copia de $t0, menos 2
			#s1 guarda t1 - 1, es decir el numero anterior
			#s3 guarda el numero 
			add $t1,$zero,$t0 #se copia lo de $t0 en $t1
			add $s1,$zero,$t1 #se copia lo de $t1 en $s1
			subi $s1, $s1,1 #se le resta 1 $s1
			add $s3, $zero,$t1 #se copia lo de $t1 en $s3
			subi $t1,$t1,2 #se le resta 2 a $a1
				
			multiplicar:
				#s3 es lo que se va sumando a s2
				add $s2, $s2,$s3 #a $s3 se le suma lo de $s2
				subi $s1,$s1,1 #se le resta 1 a $s1
				beqz $s1,copiar #si $s1 es igual a 0, salta a la etiqueta copiar
			j multiplicar

			copiar:
				#Ahora el contenido de s2 se pasa a s3 y s2 queda en 0
				#t1 va decreciendo en 1, y si llega a 0, termina el factorial
				add $s3, $zero,$s2 #se copia el contenido de $s3 en $s0
				add $s1,$zero,$t1 #se copia el contenido de $a1 en $s1
				sub $s2,$s2,$s2 #$s2 queda en 0, para poder hacer nuevamante la multiplicación
				subi $t1,$t1,1  #se le resta 1 a $t1
				beq $t1,0, resultadoFactorial #si $t1 es igual a 0, termina el factorial
			j multiplicar #sino sigue multiplicando
					
			resultadoFactorial:	
				#s0 no se puede tocar, t0 y t1 tampoco
				#Se imprime mensaje para mostrar el resultado del factorial
				li $v0, 4 #codigo 4 para imprimir un string
				la $a0, mensajeResultado #se imprime el mensaje
				syscall
				
				#Se muestra el resultado
				li $v0, 1 #codigo 1 para imprimir un entero
				move $a0,$s3 #se mueve lo que había en $s3 a $a0
				syscall
			
		#Se obtiene $a1 elevado a $t0 y se guarda en $s4
		potencia:
			#Como s4 se usa en las iteraciones anteriores, hay que resetearlo para poder usarlo
			sub $s4,$s4,$s4
			#se crea una copia de $t0 en $s0, ya que $t0 no puede ser modificado,
			#puesto que es el iterador
			add $s0,$zero,$t0 
			#se crea una copia de $s1 en $s1, puesto que este valor tampoco puede variar
			#para usarlo en las siguientes iteraciones	
			add $s1,$zero,$a1
			#se crea otra copia de $a1 en $s2
			add $s2,$zero,$a1
				
			multiplicar2:
				add $s4,$s4,$s2#se suma lo de $s2 a $s4
				subi $s1,$s1,1 #se le resta 1 a $s1
				#cuando $s1 llega a 0, siginica que completó una iteración del exponente
				#y salta a la etiqueta copiar2
				beqz $s1,copiar2 
				#sino, sigure multiplicando
			j multiplicar2
				
			copiar2:
				#se le resta 1 al exponenete, en este caso, a $s0
				subi $s0,$s0,1
				#si $s0 queda en 0, quiere decir que el exponente llegó a 0
				#y se termina la potencia
				beq $s0,1, terminaPotencia
				#sino se copia el valor de $a1 en $s1, para poder efectuar la multiplicación
				add $s1,$s1,$a1
				#lo de $s4 se pasa a $s2
				#para poder hacer la mutiplicación entre lo acumulado en $s2 y el valor ingresado ($a1)
				add $s2,$zero,$s4
				#$s4 queda en 0, para poder ir guardando el resultado final correctamente
				sub $s4,$s4,$s4
			j  multiplicar2 #salta a la subrtuina multiplicar2
					
			terminaPotencia:
				li $v0, 4 #codigo 4 para imprimir un string
				la $a0, guion #se imprime un guion
				syscall
				
				#Se muestra el resultado
				li $v0, 1 #codigo 1 para imprimir un entero
				move $a0,$s4 #se mueve lo que había en $s4 a $a0
				syscall
				
			#Los registros $s0, $s1 y $s2 quedan en 0 para volver a usarlos en la 
			#siguiente iteración
			#$s4 no puede vaciarse ya que guarda el resultado de la potencia, 
			#la cual se necesita para efectuar la divisón
			sub $s2,$s2,$s2
			sub $s1,$s1,$s1
			sub $s0,$s0,$s0
			
		#Se divide $s4 (potencia) en $s3 (factorial)
		dividir:
			parteEntera:
				#la parte entera se calcula restando lo de s3 a s4, y si $s4 queda negativo
				#se va a calcular el primer decimal
				#la parte entera está en $t2
				sub $s4,$s4,$s3 #a $s4 se le resta lo de $s3
				bltz  $s4, decimal1 #si $s4 es menor a 0, salta a decimal1
				addi $t2,$t2,1 #a $t2 se le suma 1
			j parteEntera #repite el proceso, saltando a la etiqueta parteEntera
				
			#se calcula el primer decimal
			decimal1:
				#en $t3 se guarda el decimal 1
				#como $s0 quedó negativo, se restaura su valor anterior
				#$t4 corresponde al resto de la división
				#luego se multiplica por otro registro ($t3) que almacena un 10
				add $s4,$s4,$s3 #a $s4 se le suma lo de $s3
				addi $t3,$zero,10 #a $t3 se le suma 10
				add $t4,$zero,$s4 #en $t4 se guarda lo que quedó en $s4
			
				#Aquí se multiplica el resto por 10
				#se multiplica $t3 por $t4 y el resultado se guarda en $t5
				multi:
					add $t5,$t5,$t4 #a $t5 se le suma lo de $t4
					subi $t3,$t3,1 #a $t3 se le resta 1
					beqz $t3,reset #si $t3 es igual a 0, salta a reset
				j multi #repite el proceso, saltando a la etiqueta multi
					
					
				reset:
					add $s4,$zero,$t5 #el resultado de $t5 se guarda en $s4
					
				div1:
					#se calcula la divisón entre el resto*10 y el divisor
					beqz $s4,resultadoDivision #si $s4 es igual a 0, va a la salida2, quiere decir que no existe decimal 2
					sub $s4,$s4,$s3 #a $s4 se le resta $s3
					bltz $s4,decimal2 #si $a1 es menor a 0, salta a calcular el decimal 2
					add $t3,$t3,1 # se le suma 1 a $t3, donde queda el primer decimal
				j div1 #repite el proceso, saltando a la etiqueta div1
		
			decimal2:
				#en $t6 se guarda el segundo decimal
				#$t4 corresponde al resto de la división
				#luego se multiplica por otro registro ($t3) que almacena un 10
				add $s4,$s4,$s3 #como $s4 era negativo, se restaura su valor anterior
				add $t6, $zero,10 #a $t6 se le suma 10
				add $t4,$zero,$s4 #en $t4 se guarda el resto que hay en $s4
				sub $t5,$t5,$t5 #$t5 queda en 0, ya que fue utilizado antes
					
				#Aquí se multiplica el resto por 10
				#se multiplica $t6 por $t4 y el resultado se guarda en $t5
				multi2:
					add $t5,$t5,$t4 #a $t5 se le suma lo de $t4
					subi $t6,$t6,1 #a $t6 se le resta 1
					beqz $t6,reset2 #si $t6 es igual a 0, salta a reset 2
				j multi2 #repite el proceso, saltando a la etiqueta multi2
			
				reset2:
					add $s4,$zero,$t5#a $s4 se le suma lo que había en $t5
					
				div2:
					#se calcula la división entre el segundo resto *10 y el divisor
					beqz $s4,resultadoDivision #si $s4 es 0, va a la salida2
					sub $s4,$s4,$s3 #a $s4 se le resta $s3
					bltz $s4,resultadoDivision #si $s4 es menor que 0, quiere decir que ya se calcularon los 2 decimales y va a salida2
					add $t6,$t6,1 #se le suma 1 a $t6, donde está el segundo decimal
				j div2 #repite el proceso, saltando a la etiqueta div2
				
				
			resultadoDivision:
				#Se imprime mensaje para mostrar el resultado de la división
				li $v0, 4 #codigo 4 para imprimir un string
				la $a0, resultado#se imprime en mensaje indicando el resultado de la división
				syscall #llamada al sistema
			
				#Se muestra la parte entera
				li $v0, 1 #codigo 1 para imprimir un entero
				move $a0,$t2 #se mueve lo que había en $t2 a $a0
				syscall #llamada al sistema
			
				#Se imprime un punto, para indicar decimal
				li $v0, 4 #codigo 4 para imprimir un string
				la $a0, punto #se imrpime el punto
				syscall #llamada al sistema
			
				#Se muestra el primer decimal
				li $v0, 1 #codigo 1 para imprimir un entero
				move $a0,$t3 #se mueve lo que había en $t3 a $a0
				syscall #llamada al sistema
		
				#Se muestra el segundo decimal
				li $v0, 1 #codigo 1 para imprimir un entero
				move $a0,$t6 #se mueve lo que había en $t6 a $a0
				syscall #llamada al sistema
		
				
		#en $t7 se van acumulando las partes enteras ($t2)de cada división
		acumularParteEntera:
			 add $t7,$t7,$t2 #a $t7 se le suma $t2
			
		#en $t8 se acumulan todos los primeros decimales ($t3), pero si esta suma da mayor a 10, entonces se le resta 10 a ese resultado
		#y se le suma 1 a la parte entera
		acumularDecimal1:
			add $t8,$t8,$t3 #a $t8 se le suma $t3
			bge $t8,10, sumar1ParteEntera	#si $t8 es mayor o igual a 10, salta a sumar1ParteEntera
		j acumularDecimal2 #sino va a acumular el decimal 2
			
		#Aquí se le resta 10 al resgistro que acumula el decimal 1 y se le suma 1 al que acumula la parte entera	
		sumar1ParteEntera:
			subi $t8,$t8,10 #se le resta 10 a $t8
			addi $t7,$t7,1 #se la suma 1 a $t7
				
		#en $t9 se acumulan todos los segundos decimales ($t6), pero si esta suma da mayor o igual a 10, entonces se le resta 10 a ese resultado
		#y se le suma 1 al acumulador de decimal 1
		acumularDecimal2:
			add $t9,$t9,$t6 #se suma $t6 a $t9
			bge $t9,10,sumar1Decimal1 #si $t9 es mayor o igual a 10, salta a sumar1Decimal1
		j restaurarRegistros #sino quiere decir que terminó de acumular y se restauran los registros
				
		#Aquí se le resta 10 al resgistro que acumula el decimal 2 y se le suma 1 al que acumula el decimal 1	
		sumar1Decimal1:
			subi $t9,$t9,10 #se le resta 10 a $t9
			addi $t8,$t8,1 #se le suma 1 a $t8
			#Además, si al haberle sumado 1 al decimal 1, este resulta ser mayor o igual a 10, hay que restarle 10 y sumarle 1 
			#a la parte entera
			bge $t8,10,sumar1ParteEntera2
			j restaurarRegistros #sino salta a resturar registros
		sumar1ParteEntera2:
			subi $t8,$t8,10 #se le resta 10 a $t8
			addi $t7,$t7,1 #se le suma 1 a $t7
			
		#Se restauran todos los registros a 0 para poder usarlos en la siguiente iteración
		restaurarRegistros:	
			sub $t2,$t2,$t2
			sub $t3,$t3,$t3
			sub $t4,$t4,$t4
			sub $t5,$t5,$t5
			sub $t6,$t6,$t6 
			sub $s3,$s3,$s3
			sub $s4,$s4,$s4
			
		#Al iterador $t0 se le suma 2, ya que la función seno hiperbólico es impar
		addi $t0,$t0,4
	j seno
		
	salida:	
		#Se suma el valor ingresado a la parte entera
		add $t7,$t7,$a1
		#Se imprime mensaje para mostrar el resultado final de la función seno hiperbólico
		li $v0, 4 #codigo 4 para imprimir un string
		la $a0, resultadoPositivos #se imprime el mensaje para mostrar el resultado final
		syscall #llamada al sistema 
			
		#Se muestra la parte entera
		li $v0, 1 #codigo 1 para imprimir un entero
		move $a0,$t7 #se mueve lo que había en $t7 a $a0
		syscall #llamada al sistema
			
		#Se imprime un punto, para indicar comienzo de decimales
		li $v0, 4 #codigo 4 para imprimir un string
		la $a0, punto #se imprime un punto
		syscall #llamada al sistema
			
		#Se muestra el primer decimal
		li $v0, 1 #codigo 1 para imprimir un entero
		move $a0,$t8 #se mueve lo que había en $t8 a $a0
		syscall #llamada al sistema
			
		#Se muestra el segundo decimal
		li $v0, 1 #codigo 1 para imprimir un entero
		move $a0,$t9 #se mueve lo que había en $t9 a $a0
		syscall	#llamada al sistema
		
		#Salta a calcular la suma de los negativos
		j negativos	
			
	negativos:
	
	#Se restauran todos los registros usados anteriormente para usarlos en esta subrutina
	sub $t0,$t0,$t0
	sub $t1,$t1,$t1
	sub $t2,$t2,$t2
	sub $t3,$t3,$t3
	sub $t4,$t4,$t4
	sub $t5,$t5,$t5
	sub $t6,$t6,$t6
	
	sub $s0,$s0,$s0
	sub $s1,$s1,$s1
	sub $s2,$s2,$s2
	sub $s3,$s3,$s3
	sub $s4,$s4,$s4
	#En $t0 se guarda el exponente y además se calcula el factorial de este
	#Comienza en 3, ya que que la función seno hiperbólico es impar y comienza de 1, pero el primero corresponde a los positivos
	addi $t0,$zero,3
	#Se crea una copia de $t0 en $t1, ya que se va modificando
	add $t1,$zero,$t0
	
	seno2:
		
		#si el iterador que representa el exponente y el n de factorial es mayor que 11, se sale de la subrutina
		#saltando a la subrutina que muestra el resultado final de la aproximación
		bgt $t0,11,salidaNeg 
	
		factorialNeg :
			#Aqui se obtiene el factorial de $t0
			#El factorial se guarda en s3
				
			#t1 es una copia de $t0, menos 2
			#s1 guarda t1 - 1, es decir el numero anterior
			#s3 guarda el numero 
			add $t1,$zero,$t0 #se copia lo de $t0 en $t1
			add $s1,$zero,$t1 #se copia lo de $t1 en $s1
			subi $s1, $s1,1 #se le resta 1 $s1
			add $s3, $zero,$t1 #se copia lo de $t1 en $s3
			subi $t1,$t1,2 #se le resta 2 a $a1
				
			multiplicarNeg:
				#s3 es lo que se va sumando a s2
				add $s2, $s2,$s3 #a $s3 se le suma lo de $s2
				subi $s1,$s1,1 #se le resta 1 a $s1
				beqz $s1,copiarNeg #si $s1 es igual a 0, salta a la etiqueta copiar
			j multiplicarNeg #repite el proceso, saltando a la etiqueta multiplicarNeg

			copiarNeg:
				#Ahora el contenido de s2 se pasa a s3 y s2 queda en 0
				#t1 va decreciendo en 1, y si llega a 0, termina el factorial
				add $s3, $zero,$s2 #se copia el contenido de $s3 en $s0
				add $s1,$zero,$t1 #se copia el contenido de $a1 en $s1
				sub $s2,$s2,$s2 #$s2 queda en 0, para poder hacer nuevamante la multiplicación
				subi $t1,$t1,1  #se le resta 1 a $t1
				beq $t1,0, resultadoFactorialNeg #si $t1 es igual a 0, termina el factorial
			j multiplicarNeg #sino sigue multiplicando, saltando a la etiqueta multiplicarNeg
					
			resultadoFactorialNeg:	
				#s0 no se puede tocar, t0 y t1 tampoco
				#Se imprime mensaje para mostrar el resultado del factorial
				li $v0, 4 #codigo 4 para imprimir un string
				la $a0, mensajeResultado #se imprime el mensaje
				syscall #llamada al sistema
				
				#Se muestra el resultado
				li $v0, 1 #codigo 1 para imprimir un entero
				move $a0,$s3 #se mueve lo que había en $s3 a $a0
				syscall #llamada al sistema
			
		#Se obtiene $a1 elevado a $t0 y se guarda en $s4
		potenciaNeg:
			#Como s4 se usa en las iteraciones anteriores, hay que resetearlo para poder usarlo
			sub $s4,$s4,$s4
			#se crea una copia de $t0 en $s0, ya que $t0 no puede ser modificado,
			#puesto que es el iterador
			add $s0,$zero,$t0 
			#se crea una copia de $s1 en $s1, puesto que este valor tampoco puede variar
			#para usarlo en las siguientes iteraciones	
			add $s1,$zero,$a1
			#se crea otra copia de $a1 en $s2
			add $s2,$zero,$a1
				
			multiplicar2Neg:
				add $s4,$s4,$s2#se suma lo de $s2 a $s4
				subi $s1,$s1,1 #se le resta 1 a $s1
				#cuando $s1 llega a 0, siginica que completó una iteración del exponente
				#y salta a la etiqueta copiar2
				beqz $s1,copiar2Neg 
			#sino, sigue multiplicando
			j multiplicar2Neg
				
			copiar2Neg:
				#se le resta 1 al exponenete, en este caso, a $s0
				subi $s0,$s0,1
				#si $s0 queda en 0, quiere decir que el exponente llegó a 0
				#y se termina la potencia
				beq $s0,1, terminaPotenciaNeg
				#sino se copia el valor de $a1 en $s1, para poder efectuar la multiplicación
				add $s1,$s1,$a1
				#lo de $s4 se pasa a $s2
				#para poder hacer la mutiplicación entre lo acumulado en $s2 y el valor ingresado ($a1)
				add $s2,$zero,$s4
				#$s4 queda en 0, para poder ir guardando el resultado final correctamente
				sub $s4,$s4,$s4
			j  multiplicar2Neg #salta a la etiqueta multiplicar2
					
			terminaPotenciaNeg:
				li $v0, 4 #codigo 4 para imprimir un string
				la $a0, guion #se imprime un guion
				syscall
				
				#Se muestra el resultado
				li $v0, 1 #codigo 1 para imprimir un entero
				move $a0,$s4 #se mueve lo que había en $s4 a $a0
				syscall
				
			#Los registros $s0, $s1 y $s2 quedan en 0 para volver a usarlos en la 
			#siguiente iteración
			#$s4 no puede vaciarse ya que guarda el resultado de la potencia, 
			#la cual se necesita para efectuar la divisón
			sub $s2,$s2,$s2
			sub $s1,$s1,$s1
			sub $s0,$s0,$s0
			
		#Se divide $s4 (potencia) en $s3 (factorial)
		dividirNeg:
			parteEnteraNeg:
				#la parte entera se calcula restando lo de s3 a s4, y si $s4 queda negativo
				#se va a calcular el primer decimal
				#la parte entera está en $t2
				sub $s4,$s4,$s3 #a $s4 se le resta lo de $s3
				bltz  $s4, decimal1Neg #si $s4 es menor a 0, salta a decimal1
				addi $t2,$t2,1 #a $t2 se le suma 1
			j parteEnteraNeg
				
			#se calcula el primer decimal
			decimal1Neg:
				#en $t3 se guarda el decimal 1
				#como $s0 quedó negativo, se restaura su valor anterior
				#$t4 corresponde al resto de la división
				#luego se multiplica por otro registro ($t3) que almacena un 10
				add $s4,$s4,$s3 #a $s4 se le suma lo de $s3
				addi $t3,$zero,10 #a $t3 se le suma 10
				add $t4,$zero,$s4 #en $t4 se guarda lo que quedó en $s4
			
				#Aquí se multiplica el resto por 10
				#se multiplica $t3 por $t4 y el resultado se guarda en $t5
				multiNeg:
					add $t5,$t5,$t4 #a $t5 se le suma lo de $t4
					subi $t3,$t3,1 #a $t3 se le resta 1
					beqz $t3,resetNeg #si $t3 es igual a 0, salta a reset
				j multiNeg 
					
					
				resetNeg:
					add $s4,$zero,$t5 #el resultado de $t5 se guarda en $s4
					
				div1Neg:
					#se calcula la divisón entre el resto*10 y el divisor
					beqz $s4,resultadoDivisionNeg #si $s4 es igual a 0, va a la salida2, quiere decir que no existe decimal 2
					sub $s4,$s4,$s3 #a $s4 se le resta $s3
					bltz $s4,decimal2Neg  #si $a1 es menor a 0, salta a calcular el decimal 2
					add $t3,$t3,1 # se le suma 1 a $t3, donde queda el primer decimal
				j div1Neg
		
			decimal2Neg:
				#en $t6 se guarda el segundo decimal
				#$t4 corresponde al resto de la división
				#luego se multiplica por otro registro ($t3) que almacena un 10
				add $s4,$s4,$s3 #como $s4 era negativo, se restaura su valor anterior
				add $t6, $zero,10 #a $t6 se le suma 10
				add $t4,$zero,$s4 #en $t4 se guarda el resto que hay en $s4
				sub $t5,$t5,$t5 #$t5 queda en 0, ya que fue utilizado antes
					
				#Aquí se multiplica el resto por 10
				#se multiplica $t6 por $t4 y el resultado se guarda en $t5
				multi2Neg:
					add $t5,$t5,$t4 #a $t5 se le suma lo de $t4
					subi $t6,$t6,1 #a $t6 se le resta 1
					beqz $t6,reset2Neg #si $t6 es igual a 0, salta a reset 2
				j multi2Neg
			
				reset2Neg:
					add $s4,$zero,$t5#a $s4 se le suma lo que había en $t5
					
				div2Neg:
					#se calcula la división entre el segundo resto *10 y el divisor
					beqz $s4,resultadoDivisionNeg  #si $s4 es 0, va a la salida2
					sub $s4,$s4,$s3 #a $s4 se le resta $s3
					bltz $s4,resultadoDivisionNeg #si $s4 es menor que 0, quiere decir que ya se calcularon los 2 decimales y va a salida2
					add $t6,$t6,1 #se le suma 1 a $t6, donde está el segundo decimal
				j div2Neg
				
				
			resultadoDivisionNeg:
				#Se imprime mensaje para mostrar el resultado de la división
				li $v0, 4 #codigo 4 para imprimir un string
				la $a0, resultado#se imprime en mensaje indicando el resultado de la división
				syscall #llamada al sistema
			
				#Se muestra la parte entera
				li $v0, 1 #codigo 1 para imprimir un entero
				move $a0,$t2 #se mueve lo que había en $t0 a $a0
				syscall #llamada al sistema
			
				#Se imprime un punto, para indicar decimal
				li $v0, 4 #codigo 4 para imprimir un string
				la $a0, punto #se imrpime el punto
				syscall #llamada al sistema
			
				#Se muestra el primer decimal
				li $v0, 1 #codigo 1 para imprimir un entero
				move $a0,$t3 #se mueve lo que había en $t3 a $a0
				syscall #llamada al sistema
		
				#Se muestra el segundo decimal
				li $v0, 1 #codigo 1 para imprimir un entero
				move $a0,$t6 #se mueve lo que había en $t6 a $a0
				syscall #llamada al sistema
		
				
		#en $t7 se van acumulando las partes enteras de cada división
		acumularParteEnteraNeg:
			 add $s5,$s5,$t2 #a $t7 se le suma $t2
			
		#en $t8 se acumulan todos los primeros decimales, pero si esta suma da mayor a 10, entonces se le resta 10 a ese resultado
		#y se le suma 1 a la parte entera
		acumularDecimal1Neg:
			add $s6,$s6,$t3 #a $t8 se le suma $t3
			bge $s6,10, sumar1ParteEnteraNeg	#si $t8 es mayor o igual a 10, salta a sumar1ParteEntera
		j acumularDecimal2Neg  #sino va a acumular el decimal 2
			
		#Aquí se le resta 10 al resgistro que acumula el decimal 1 y se le suma 1 al que acumula la parte entera	
		sumar1ParteEnteraNeg:
			subi $s6,$s6,10 #se le resta 10 a $t8
			addi $s5,$s5,1 #se la suma 1 a $t7
				
		#en $t9 se acumulan todos los segundos decimales, pero si esta suma da mayor o igual a 10, entonces se le resta 10 a ese resultado
		#y se le suma 1 al acumulador de decimal 1
		acumularDecimal2Neg:
			add $s7,$s7,$t6 #se suma $t6 a $t9
			bge $s7,10,sumar1Decimal1Neg #si $t9 es mayor o igual a 10, salta a sumar1Decimal1
		j restaurarRegistrosNeg #sino quiere decir que terminó de acumular y se restauran los registros
				
		#Aquí se le resta 10 al resgistro que acumula el decimal 2 y se le suma 1 al que acumula el decimal 1	
		sumar1Decimal1Neg:
			subi $s7,$s7,10 #se le resta 10 a $t9
			addi $s6,$s6,1 #se le suma 1 a $t8
			#Además, si al haberle sumado 1 al decimal 1, este resulta ser mayor o igual a 10, hay que restarle 10 y sumarle 1 
			#a la parte entera
			bge $s6,10,sumar1ParteEntera2Neg
			j restaurarRegistrosNeg #sino salta a restaurar los registros
		sumar1ParteEntera2Neg:
			subi $s6,$s6,10 #se le resta 10 a $s6
			addi $s5,$s5,1 #se le suma 1 a $s5
			
		#Se restauran todos los registros a 0 para poder usarlos en la siguiente iteración
		restaurarRegistrosNeg:	
			sub $t2,$t2,$t2
			sub $t3,$t3,$t3
			sub $t4,$t4,$t4
			sub $t5,$t5,$t5
			sub $t6,$t6,$t6 
			sub $s3,$s3,$s3
			sub $s4,$s4,$s4
			
		#Al iterador $t0 se le suma 2, ya que la función seno hiperbólico es impar
		addi $t0,$t0,4
				
	j seno2	
		
	salidaNeg:	
		#Se imprime mensaje para mostrar el resultado final de la función seno hiperbólico
		li $v0, 4 #codigo 4 para imprimir un string
		la $a0, resultadoNegativos #se imprime el mensaje para mostrar el resultado final
		syscall #llamada al sistema 
			
		#Se muestra la parte entera
		li $v0, 1 #codigo 1 para imprimir un entero
		move $a0,$s5 #se mueve lo que había en $t7 a $a0
		syscall #llamada al sistema
			
		#Se imprime un punto, para indicar comienzo de decimales
		li $v0, 4 #codigo 4 para imprimir un string
		la $a0, punto #se imprime un punto
		syscall #llamada al sistema
			
		#Se muestra el primer decimal
		li $v0, 1 #codigo 1 para imprimir un entero
		move $a0,$s6 #se mueve lo que había en $t8 a $a0
		syscall #llamada al sistema
			
		#Se muestra el segundo decimal
		li $v0, 1 #codigo 1 para imprimir un entero
		move $a0,$s7 #se mueve lo que había en $t9 a $a0
		syscall	#llamada al sistema
		
		#Salta a terminar el programa
		j restarResultados
	
	#Aquí se resta el resultado de la parte positiva con la negativa
	restarResultados:
		#Si $t7 es menor que $s5, salta a primeroMenor
		blt $t7,$s5,primeroMenor
		#Aquí se restan los segundos decimales, donde $s7 representa el segundo decimal del resultado negativo
		#y $t9 representa el segundo decimal del resultado positivo
		restarDecimales2:
			#Para el caso en que el valor que se va a restar es mayor que el valor al que se le resta
			#por ejemplo 2.35-1.39
			bgt $s7,$t9,aux2 #si $s7 es mayor que $t9, salta a la etiqueta aux2
			beqz $t9,aux2 #si$t9 es igual a 0, salta a la etiqueta aux2
			sub $t9,$t9,$s7 #sino realiza la resta entre $t9 y $s7
			j restarDecimales1 #salta restar los primeros decimales
		aux2:
			addi $t9,$t9,10 #se le suma 10 al registro $t9
			sub $t9,$t9,$s7 #se realiza la resta entre $t9 y $s7
			subi $t8,$t8,1 #se le resta 1 a $t8(primer decimal), debido a la "reserva"
			bltz $t8,aux3 #si $t8 queda en 0, salta a aux3
			j restarDecimales1 #sino va a calcular la resta entre los primeros decimales
		aux3:
			addi $t8,$t8,10 #se le suma 10 a $t8
			subi $t7,$t7,1 #se le resta 1 a $t7(parte entera), por la "reserva"
		
		#Aquí se restan los primeros decimales, donde $s6 representa el segundo decimal del resultado negativo
		#y $t8 representa el primer decimal del resultado positivo
		restarDecimales1:
			#Para el caso en que el valor que se va a restar es mayor que el valor al que se le resta
			#por ejemplo 2.39-1.54
			bgt $s6,$t8,aux1 #si $s6 es mayor que $t8, salta a la etiqueta aux1
			beqz $t8,aux1 #si $t8 es igual a 0, salta a la etiqueta aux1
			sub $t8,$t8,$s6 #sino realiza la resta entre $t8 y $s6
			j restarParteEntera #salta a restar las partes enteras
		aux1:
			addi $t8,$t8,10 #se le suma 10 al registro $t8
			sub $t8,$t8,$s6 #se realiza la resta entre $t8 y $s6
			subi $t7,$t7,1 #se le resta 1 a $t7(parte entera), debido a la "reserva"
			
		restarParteEntera:
			#se restan las partes enteras
			sub $t7,$t7,$s5 #se resta $t7 y $s5
		j salidaFinal #salta a salidaFinal
		
	primeroMenor:
		#Se intercambian las partes enteras, dejando $s5 en $t7 y viceversa
		add $t0,$zero,$s5 #se crea una copia de $s5 en $t0
		add $t1,$zero,$t7 #se crea una copia de $t7 en $t1
		add $t7,$zero,$t0 #lo de $t0 se copia en $t7
		add $s5,$zero,$t1 #lo de $t1 se copia en $s5
		#Se intercambian los primeros decimales, dejando $s6 en $t8 y viceversa
		add $t0,$zero,$s6 #se crea una copia de $s6 en $t0
		add $t1,$zero,$t8 #se crea una copia de $t8 en $t1
		add $t8,$zero,$t0 #lo de $t0 se copia en $t8
		add $s6,$zero,$t1 #lo de $t1 se copia en $s6
		#Se intercambian los segundos decimales, dejando $s7 en $t9 y viceversa
		add $t0,$zero,$s7 #se crea una copia de $s7 en $t0
		add $t1,$zero,$t9 #se crea una copia de $t9 en $t1
		add $t9,$zero,$t0 #lo de $t0 se copia en $t9
		add $s7,$zero,$t1 #lo de $t1 se copia en $s7
		
		#Aquí se restan los segundos decimales, donde $s7 representa el segundo decimal del resultado negativo
		#y $t9 representa el segundo decimal del resultado positivo
		restarDecimales2aux:
			#Para el caso en que el valor que se va a restar es mayor que el valor al que se le resta
			#por ejemplo 2.35-1.39
			bgt $s7,$t9,aux2aux #si $s7 es mayor que $t9, salta a la etiqueta aux2aux
			beqz $t9,aux2aux #si$t9 es igual a 0, salta a la etiqueta aux2aux
			sub $t9,$t9,$s7 #sino realiza la resta entre $t9 y $s7
			j restarDecimales1aux #salta restar los primeros decimales
		aux2aux:
			addi $t9,$t9,10 #se le suma 10 al registro $t9
			sub $t9,$t9,$s7 #se realiza la resta entre $t9 y $s7
			subi $t8,$t8,1 #se le resta 1 a $t8(primer decimal), debido a la "reserva"
			bltz $t8,aux3aux #si $t8 queda en 0, salta a aux3aux
			j restarDecimales1aux #sino va a calcular la resta entre los primeros decimales
		aux3aux:
			addi $t8,$t8,10 #se le suma 10 a $t8
			subi $t7,$t7,1 #se le resta 1 a $t7(parte entera), por la "reserva"
		
		#Aquí se restan los primeros decimales, donde $s6 representa el segundo decimal del resultado negativo
		#y $t8 representa el primer decimal del resultado positivo
		restarDecimales1aux:
			#Para el caso en que el valor que se va a restar es mayor que el valor al que se le resta
			#por ejemplo 2.39-1.54
			bgt $s6,$t8,aux1aux #si $s6 es mayor que $t8, salta a la etiqueta aux1aux
			beqz $t8,aux1aux #si $t8 es igual a 0, salta a la etiqueta aux1aux
			sub $t8,$t8,$s6 #sino realiza la resta entre $t8 y $s6
			j restarParteEnteraaux #salta a restar las partes enteras
		aux1aux: 
			addi $t8,$t8,10 #se le suma 10 al registro $t8
			sub $t8,$t8,$s6 #se realiza la resta entre $t8 y $s6
			subi $t7,$t7,1 #se le resta 1 a $t7(parte entera), debido a la "reserva"
			
		#se restan las partes enteras
		restarParteEnteraaux:
			sub $t7,$t7,$s5 #se resta $t7 y $s5
			
		#Como en este caso, el primero es menor, hay que transformar la parte entera a negativa, para poder
		#imprimir el resultado final de manera correcta
		add $t0,$zero,$t7 #en $t0 se suma 0 y lo de $t7
		sub $t7,$zero,$t0 #luego, en $t7 se guarda la resta entre 0 y lo de $t0
		
		#Además, si la parte entera da 0, hay que agregar un signo negativo
		beqz $t7,signoNegativo
		#sino salta a la salidaFinal
		j salidaFinal
		
		signoNegativo:
			#Se imprime mensaje para mostrar el resultado final de la función seno
			li $v0, 4 #codigo 4 para imprimir un string
			la $a0, resultadoFinal #se imprime el mensaje para mostrar el resultado final
			syscall #llamada al sistema 
			
			#Se imprime mensaje para mostrar un signo negativo
			li $v0, 4 #codigo 4 para imprimir un string
			la $a0, signo #se imprime el signo negativo
			syscall #llamada al sistema 
			j mostrar #salta a mostrar lo restante, parte entera, coma, decimal 1 y decimal 2
	salidaFinal:	
		#Se imprime mensaje para mostrar el resultado final de la función seno 
		li $v0, 4 #codigo 4 para imprimir un string
		la $a0, resultadoFinal #se imprime el mensaje para mostrar el resultado final
		syscall #llamada al sistema 
		
		mostrar:	
		#Se muestra la parte entera
		li $v0, 1 #codigo 1 para imprimir un entero
		move $a0,$t7 #se mueve lo que había en $t7 a $a0
		syscall #llamada al sistema
			
		#Se imprime un punto, para indicar comienzo de decimales
		li $v0, 4 #codigo 4 para imprimir un string
		la $a0, punto #se imprime un punto
		syscall #llamada al sistema
			
		#Se muestra el primer decimal
		li $v0, 1 #codigo 1 para imprimir un entero
		move $a0,$t8 #se mueve lo que había en $t8 a $a0
		syscall #llamada al sistema
			
		#Se muestra el segundo decimal
		li $v0, 1 #codigo 1 para imprimir un entero
		move $a0,$t9 #se mueve lo que había en $t9 a $a0
		syscall	#llamada al sistema
		
		j terminarPrograma #salta a terminar el programa
	error:
		#Se imprime mensaje de error
		li $v0, 4 #codigo 4 para imprimir un string
		la $a0, mensajeError #Se imprime el mensaje de error
		syscall	#llamada al sistema 

	terminarPrograma:
		#Se termina el programa
		li $v0, 10 #código 10 para terminar programa
		syscall #llamada al sistema
