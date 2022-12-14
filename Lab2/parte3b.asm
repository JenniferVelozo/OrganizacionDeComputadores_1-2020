.data
	numero: .asciiz "\nIngrese un numero entero no negativo: "
	mensajeError: .asciiz "\nDebe ingresar un numero entero no negativo"
	mensajeResultado: .asciiz "\n\nFactorial y potencia: "
	guion: .asciiz " - "
	resultado: .asciiz "\nEl resultado de la divisi?n potencia/factorial es: "
	punto: .asciiz "."
	resultadoFinal: .asciiz "\n\nLa aproximaci?n para la funci?n seno hiperb?lico\nen torno a 0, de orden 11, es: "
.text
	#174 instrucciones
	#Este programa acepta un n?mero entero hasta 7 puesto que con el n?mero 8, al elevarlo a 11, se sale del
	#l?mite que soporta un registro
	li $v0, 4 #codigo 4 para imprimir un string
	la $a0, numero #se imprime un mensaje para ingresar el n?mero
	syscall #llamada al sistema
	
	#Se obtiene el valor
	li $v0,5 #se pone v0 en 5 para recibir un entero
	syscall #llamada al sistema
	
	move $a1, $v0 #se mueve el contenido de v0 a a1
	
	bltz  $a1,error #si el valor ingresado es menor a 0, salta a la etiqueta error
	beqz $a1,salida #si el valor ingresado es 0, salta a la salida, entregando como resultado 0
	
	#En $t0 se guarda el exponente y adem?s se calcula el factorial de este
	#Comienza en 3, ya que que la funci?n seno hiperb?lico es impar, pero el valor ingresado se suma al final
	addi $t0,$zero,3
	#Se crea una copia de $t0 en $t1, ya que se va modificando
	add $t1,$zero,$t0
	
	#se hace el llamado a la subrutina
	jal senoHiperbolico
	
	senoHiperbolico:
		#si el iterador que representa el exponente y el n de factorial es mayor que 11, se sale de la subrutina
		#saltando a la subrutina que muestra el resultado final de la aproximaci?n
		bgt $t0,11,salida 
	
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
				sub $s2,$s2,$s2 #$s2 queda en 0, para poder hacer nuevamante la multiplicaci?n
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
				move $a0,$s3 #se mueve lo que hab?a en $s3 a $a0
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
				#cuando $s1 llega a 0, siginica que complet? una iteraci?n del exponente
				#y salta a la etiqueta copiar2
				beqz $s1,copiar2 
				#sino, sigure multiplicando
			j multiplicar2
				
			copiar2:
				#se le resta 1 al exponenete, en este caso, a $s0
				subi $s0,$s0,1
				#si $s0 queda en 0, quiere decir que el exponente lleg? a 0
				#y se termina la potencia
				beq $s0,1, terminaPotencia
				#sino se copia el valor de $a1 en $s1, para poder efectuar la multiplicaci?n
				add $s1,$s1,$a1
				#lo de $s4 se pasa a $s2
				#para poder hacer la mutiplicaci?n entre lo acumulado en $s2 y el valor ingresado ($a1)
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
				move $a0,$s4 #se mueve lo que hab?a en $s4 a $a0
				syscall
				
			#Los registros $s0, $s1 y $s2 quedan en 0 para volver a usarlos en la 
			#siguiente iteraci?n
			#$s4 no puede vaciarse ya que guarda el resultado de la potencia, 
			#la cual se necesita para efectuar la divis?n
			sub $s2,$s2,$s2
			sub $s1,$s1,$s1
			sub $s0,$s0,$s0
			
		#Se divide $s4 (potencia) en $s3 (factorial)
		dividir:
			parteEntera:
				#la parte entera se calcula restando lo de s3 a s4, y si $s4 queda negativo
				#se va a calcular el primer decimal
				#la parte entera est? en $t2
				sub $s4,$s4,$s3 #a $s4 se le resta lo de $s3
				bltz  $s4, decimal1 #si $s4 es menor a 0, salta a decimal1
				addi $t2,$t2,1 #a $t2 se le suma 1
			j parteEntera
				
			#se calcula el primer decimal
			decimal1:
				#en $t3 se guarda el decimal 1
				#como $s0 qued? negativo, se restaura su valor anterior
				#$t4 corresponde al resto de la divisi?n
				#luego se multiplica por otro registro ($t3) que almacena un 10
				add $s4,$s4,$s3 #a $s4 se le suma lo de $s3
				addi $t3,$zero,10 #a $t3 se le suma 10
				add $t4,$zero,$s4 #en $t4 se guarda lo que qued? en $s4
			
				#Aqu? se multiplica el resto por 10
				#se multiplica $t3 por $t4 y el resultado se guarda en $t5
				multi:
					add $t5,$t5,$t4 #a $t5 se le suma lo de $t4
					subi $t3,$t3,1 #a $t3 se le resta 1
					beqz $t3,reset #si $t3 es igual a 0, salta a reset
				j multi
					
					
				reset:
					add $s4,$zero,$t5 #el resultado de $t5 se guarda en $s4
					
				div1:
					#se calcula la divis?n entre el resto*10 y el divisor
					beqz $s4,resultadoDivision #si $s4 es igual a 0, va a la salida2, quiere decir que no existe decimal 2
					sub $s4,$s4,$s3 #a $s4 se le resta $s3
					bltz $s4,decimal2 #si $a1 es menor a 0, salta a calcular el decimal 2
					add $t3,$t3,1 # se le suma 1 a $t3, donde queda el primer decimal
				j div1
		
			decimal2:
				#en $t6 se guarda el segundo decimal
				#$t4 corresponde al resto de la divisi?n
				#luego se multiplica por otro registro ($t3) que almacena un 10
				add $s4,$s4,$s3 #como $s4 era negativo, se restaura su valor anterior
				add $t6, $zero,10 #a $t6 se le suma 10
				add $t4,$zero,$s4 #en $t4 se guarda el resto que hay en $s4
				sub $t5,$t5,$t5 #$t5 queda en 0, ya que fue utilizado antes
					
				#Aqu? se multiplica el resto por 10
				#se multiplica $t6 por $t4 y el resultado se guarda en $t5
				multi2:
					add $t5,$t5,$t4 #a $t5 se le suma lo de $t4
					subi $t6,$t6,1 #a $t6 se le resta 1
					beqz $t6,reset2 #si $t6 es igual a 0, salta a reset 2
				j multi2
			
				reset2:
					add $s4,$zero,$t5#a $s4 se le suma lo que hab?a en $t5
					
				div2:
					#se calcula la divisi?n entre el segundo resto *10 y el divisor
					beqz $s4,resultadoDivision #si $s4 es 0, va a la salida2
					sub $s4,$s4,$s3 #a $s4 se le resta $s3
					bltz $s4,resultadoDivision #si $s4 es menor que 0, quiere decir que ya se calcularon los 2 decimales y va a salida2
					add $t6,$t6,1 #se le suma 1 a $t6, donde est? el segundo decimal
				j div2
				
				
			resultadoDivision:
				#Se imprime mensaje para mostrar el resultado de la divisi?n
				li $v0, 4 #codigo 4 para imprimir un string
				la $a0, resultado#se imprime en mensaje indicando el resultado de la divisi?n
				syscall #llamada al sistema
			
				#Se muestra la parte entera
				li $v0, 1 #codigo 1 para imprimir un entero
				move $a0,$t2 #se mueve lo que hab?a en $t0 a $a0
				syscall #llamada al sistema
			
				#Se imprime un punto, para indicar decimal
				li $v0, 4 #codigo 4 para imprimir un string
				la $a0, punto #se imrpime el punto
				syscall #llamada al sistema
			
				#Se muestra el primer decimal
				li $v0, 1 #codigo 1 para imprimir un entero
				move $a0,$t3 #se mueve lo que hab?a en $t3 a $a0
				syscall #llamada al sistema
		
				#Se muestra el segundo decimal
				li $v0, 1 #codigo 1 para imprimir un entero
				move $a0,$t6 #se mueve lo que hab?a en $t6 a $a0
				syscall #llamada al sistema
				
		#en $t7 se van acumulando las partes enteras de cada divisi?n
		acumularParteEntera:
			 add $t7,$t7,$t2 #a $t7 se le suma $t2
			
		#en $t8 se acumulan todos los primeros decimales, pero si esta suma da mayor a 10, entonces se le resta 10 a ese resultado
		#y se le suma 1 a la parte entera
		acumularDecimal1:
			add $t8,$t8,$t3 #a $t8 se le suma $t3
			bge $t8,10, sumar1ParteEntera	#si $t8 es mayor o igual a 10, salta a sumar1ParteEntera
		j acumularDecimal2 #sino va a acumular el decimal 2
			
		#Aqu? se le resta 10 al resgistro que acumula el decimal 1 y se le suma 1 al que acumula la parte entera	
		sumar1ParteEntera:
			subi $t8,$t8,10 #se le resta 10 a $t8
			addi $t7,$t7,1 #se la suma 1 a $t7
				
		#en $t9 se acumulan todos los segundos decimales, pero si esta suma da mayor o igual a 10, entonces se le resta 10 a ese resultado
		#y se le suma 1 al acumulador de decimal 1
		acumularDecimal2:
			add $t9,$t9,$t6 #se suma $t6 a $t9
			bge $t9,10,sumar1Decimal1 #si $t9 es mayor o igual a 10, salta a sumar1Decimal1
		j restaurarRegistros #sino quiere decir que termin? de acumular y se restauran los registros
				
		#Aqu? se le resta 10 al resgistro que acumula el decimal 2 y se le suma 1 al que acumula el decimal 1	
		sumar1Decimal1:
			subi $t9,$t9,10 #se le resta 10 a $t9
			addi $t8,$t8,1 #se le suma 1 a $t8
			#Adem?s, si al haberle sumado 1 al decimal 1, este resulta ser mayor o igual a 10, hay que restarle 10 y sumarle 1 
			#a la parte entera
			bge $t8,10,sumar1ParteEntera2
			j restaurarRegistros #sino salta a restaurar registros
		sumar1ParteEntera2:
			subi $t8,$t8,10 #se le resta 10 a $t8
			addi $t7,$t7,1 #se le suma 1 a $t7
			
		#Se restauran todos los registros a 0 para poder usarlos en la siguiente iteraci?n
		restaurarRegistros:	
			sub $t2,$t2,$t2
			sub $t3,$t3,$t3
			sub $t4,$t4,$t4
			sub $t5,$t5,$t5
			sub $t6,$t6,$t6 
			sub $s3,$s3,$s3
			sub $s4,$s4,$s4
			
		#Al iterador $t0 se le suma 2, ya que la funci?n seno hiperb?lico es impar
		addi $t0,$t0,2
			
			
	j senoHiperbolico	
		
	salida:	
		#Se suma el valor ingresado a la parte entera
		add $t7,$t7,$a1
		#Se imprime mensaje para mostrar el resultado final de la funci?n seno hiperb?lico
		li $v0, 4 #codigo 4 para imprimir un string
		la $a0, resultadoFinal #se imprime el mensaje para mostrar el resultado final
		syscall #llamada al sistema 
			
		#Se muestra la parte entera
		li $v0, 1 #codigo 1 para imprimir un entero
		move $a0,$t7 #se mueve lo que hab?a en $t7 a $a0
		syscall #llamada al sistema
			
		#Se imprime un punto, para indicar comienzo de decimales
		li $v0, 4 #codigo 4 para imprimir un string
		la $a0, punto #se imprime un punto
		syscall #llamada al sistema
			
		#Se muestra el primer decimal
		li $v0, 1 #codigo 1 para imprimir un entero
		move $a0,$t8 #se mueve lo que hab?a en $t8 a $a0
		syscall #llamada al sistema
			
		#Se muestra el segundo decimal
		li $v0, 1 #codigo 1 para imprimir un entero
		move $a0,$t9 #se mueve lo que hab?a en $t9 a $a0
		syscall	#llamada al sistema
		
		#Salta a terminar el programa
		j terminarPrograma
	
	error:
		#Se imprime mensaje de error
		li $v0, 4 #codigo 4 para imprimir un string
		la $a0, mensajeError #Se imprime el mensaje de error
		syscall	#llamada al sistema 

	terminarPrograma:
		#Se termina el programa
		li $v0, 10 #c?digo 10 para terminar programa
		syscall #llamada al sistema
