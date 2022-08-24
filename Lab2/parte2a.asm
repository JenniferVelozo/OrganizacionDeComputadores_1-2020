.data
	#mensaje para imprimir por pantalla
	resultado: .asciiz "El resultado de la multiplicación es: "
.text
	#56 instrucciones
	#en $a1 se guarda el primer número
	addi $a1, $zero, 65952
	#en $a2 se guarda el segundo número
	addi $a2, $zero, -28914
	#se copian los valores en $t1 y $t2 para no perder su valor original
	add $t1,$zero,$a1
	add $t2,$zero,$a2
	
	#se hace el llamado a la subrutina
	jal multiplicar
	#luego de obtener el resultado de la multiplicación, se muestra el resultado
	jal mostrarResultado
	
	#Subrutina para multiplicar
	multiplicar:
		#En $s0 se guarda el resultado final
		addi $sp,$sp,-4 # ajustar la pila para 1 elemento
		sw $s0, 0($sp) # guardar la dirección de retorno

		#se revisarán si son menores que 0.
		#Si $t1 es menor que 0, $t0 se convierte en 1
		slti $t0, $t1, 0
		#Si $t2 es menor que 0, $t3 se convierte en 1
		slti $t3, $t2, 0
		
		RevisarSignos:
			#Si ambos son negativos, o ambos positivos, salta a CambiarSignos
			#ambos negativos: $t0=$t3=1 ; ambos positivos: $t0=$t3=0
			beq $t0, $t3, CambiarSignos
			
			#Sino, quiere decir que uno de ellos es negativo y el otro positivo
			#Si $t1 < $t2, entonces $t0 se convierte en 1 y salta a MultNeg1
			#Pregunta si $a1 es negativo
			slt $t0, $t1, $t2
			beq $t0, 1, MultNeg1
		#Sino, a MultNeg2. Quiere decir que $t2 es negativo
		j MultNeg2

		#Si los números son negativos, se convertirán a positivos.
		CambiarSignos:
			#Como $t0=$t1, se pregunta si $t0 es igual a 0, para saber si es positivo
			#y así realizar la multiplicación de positivos 
			beqz $t0, MultPos
			
			#Si $t0 es igual 1, signifca que ambos son negativos 
			#El primer numero se convierte en positivo
			#$t1= 0 - $t1, se tiene 0 - (numero negativo), ejemplo: 0 - (-5)=5
			sub $t1, $zero, $t1
			
			#El segundo numero se convierte en positivo
			#$t2= 0 - $t2
			sub $t2, $zero, $t2
			
		#Luego de que ambos numero negativos hayan quedado positivos, salta a la etiqueta que realiza la multiplicación
		#de dos positivos
		j MultPos

		#Subrutina para multiplicar, dando un resultado positivo.
		MultPos:

			#Esto se hace para ir acumulando el número mayor en el resultado e ir restando 1 al menor, 
			#para que no tome más tiempo en calcular el resultado final
			bge $t1,$t2,Numero1Mayor #si $t1 es mayor que $a2, salta a la etiqueta indicada
			bge $t2,$t1,Numero2Mayor #si $t2 es mayor que $a1, salta a la etiqueta indicada
			
			Numero1Mayor:
				#Si $t2 está en 0, es porque se terminó de multiplciar.
				beqz $t2, salida
				#Sino
				#se va acumulando el primer número en $s0, y luego se le resta 1 al número 2(menor)
				add $s0, $s0, $t1 #se suma $t1 a $s0
				subi $t2, $t2, 1 #se le resta 1 a $t2
				j Numero1Mayor #repite el ciclo, saltando a la etiqueta Numero1Mayor
			
			Numero2Mayor:
				#Si $a1 está en 0, es porque se terminó de multiplciar.
				beqz $t1, salida
				#Sino
				#se va acumulando el segundo número en $s0, y luego se le resta 1 al número 1 (menor)
				add $s0, $s0, $t2 #se suma $t2 a $s0
				subi $t1, $t1, 1 #se le resta 1 a $t1
				j Numero2Mayor #repite el ciclo, saltando a la etiqueta Numero2Mayor

		#Subrutina para multiplicar con resultado negativo (si $t1 es negativo).
		MultNeg1:
			#Si $t1 está en 0, es porque se terminó de multiplciar.
			beqz $t1, salida
			#Para el caso en que el segundo número sea 0, y no realice instrucciones extras
			beqz $t2, salida
			#Sino
			#se va restando $t2 (segundo numero, el positivo) a s0
			#se resta para que el resultado final de negativo
			sub $s0, $s0, $t2
			#se le suma 1 al número que es negativo, para que pueda llegar a 0
			addi $t1, $t1, 1
			j MultNeg1 #repite el ciclo, saltando a la etiqueta MultNeg1

		#Subrutina para multiplicar con resultado negativo (si $t2 es negativo).
		MultNeg2:
			#Si $t2 está en 0, es porque se terminó de multiplciar.
			beqz $t2, salida
			#para el caso en que el primer número sea 0, y no realice instrucciones extras
			beqz $t1, salida
			#Sino
			#se le va restando el numero positivo a $s0
			#se resta para que el resultado final de negativo
			sub $s0, $s0, $t1
			#se le suma 1 al numero negativo, para que vaya decreciendo hasta llegar a 0
			addi $t2, $t2, 1
			j MultNeg2 #repite el ciclo, saltando a la etiqueta MultNeg2
		
		salida:
			add $v1,$s0,$zero #se guarda en $v1 el resultado de la multiplicación, para poder retornar
		
			
		lw $s0, 0($sp) # restaura registro $s0 para el llamador
		addi $sp,$sp,4 # ajusta la pila para eliminar 1 campo
		
		jr $ra # salto de retorno a la rutina de llamada

	mostrarResultado:
		#Se imprime mensaje para mostrar el resultado de la multiplicación
		li $v0, 4 #codigo 4 para imprimir un string
		la $a0, resultado #se imprime el mensaje
		syscall #llamada al sistema
		
		#Se muestra el resultado
		li $v0, 1 #codigo 1 para imprimir un entero
		move $a0,$v1 #se mueve lo que había en $v1 a $a0
		syscall #llamada al sistema
		
	terminarPrograma:
		#Se termina el programa
		li $v0, 10 #código 10 para terminar programa
		syscall #llamada al sistema
