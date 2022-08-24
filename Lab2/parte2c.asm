.data
	#mensajes para imprimir por pantalla
	pedirNumero1: .asciiz "\nPor favor ingrese el dividendo positivo: "
	pedirNumero2: .asciiz " Por favor ingrese el divisor, mayor a 0: "
	resultado: .asciiz "El resultado de la división es: "
	punto: .asciiz "."
	mensajeError: .asciiz "\nEl divisor es 0, por lo tanto no es posible calcular la división"
.text
	#69 instrucciones
	loop:
		li $v0, 4 #codigo 4 para imprimir un string
		la $a0, pedirNumero1 #se imprime un mensaje para ingresar el primer número
		syscall #llamada al sistema
	
		#Se obtiene el primer número
		li $v0,5 #se pone v0 en 5 para recibir un entero
		syscall #llamada al sistema
		move $a1, $v0 #se mueve el contenido de v0 a a1, el primer número ingresado
	#si el dividendo es menor a 0, vuelve a pedirlo
	bltz $a1,loop

	loop2: 
		li $v0, 4 #codigo 4 para imprimir un string
		la $a0, pedirNumero2 #se imprime un mensaje para ingresar el segundo número
		syscall #llamada al sistema
	
		#Se obtiene el segundo número
		li $v0,5 #se pone v0 en 5 para recibir un entero
		syscall #llamada al sistema
		move $a2, $v0 #se mueve el contenido de v0 a a2, el segundo número ingresado
	
	#si el divisor es menor o igual a 0, vuelve a pedirlo
	blez  $a2,loop2
	
	#se hace el llamado a la subrutina
	jal dividir
			
	dividir:
		#Para entender mejor, por ejemplo se tiene $a1=1 y $a2=3
		#a $a1 se le va restando lo de $a2, y si este es menor o igual a 0, salta a la salida
		#si $a1 es queda menor a 0, salta a calcular el primer decimal
		#sino se le suma 1 a $t0, que es donde se guarda la parte entera.
		#Cabe destacar que si el dividendo es un numero muy grande y el divisor es muy pequeño, por ejemplo
		#4566356/2, tomará mucho tiempo en ejecutar, puesto que, en este caso se irá restando 2 unidades al numero grande
		parteEntera:
		#la parte entera está en $t0
			beqz $a1, salida #si $a1 es igual a 0, salta a la salida
			sub $a1,$a1,$a2 #a $a1 se le resta lo de $a2
			bltz  $a1, decimal1 #si $a1 es menor a 0, salta a decimal1
			addi $t0,$t0,1 #a $t0 se le suma 1
			j parteEntera
		
		decimal1:
		#en $t1 se guarda el decimal 1
			#como $s0 quedó negativo, se restaura su valor a positivo
			add $a1,$a1,$a2 #a $a1 se le suma lo de $a2
			addi $t1,$zero,10 #a $t1 se le suma 10
			
			#Aquí se multiplica el resto por 10
			multi:
				add $t2,$t2,$a1 #a $t2 se le suma lo de $a1
				subi $t1,$t1,1 #a $t1 se l resta 1
				beqz $t1,reset #si $t1 es igual a 0, salta a reset
			j multi
		
		reset:
			add $a1,$zero,$t2	# el resultado de $t2 se guarda en $a1
			sub $t2,$t2,$t2		#se resetea el registro $t2
			div1:
				#se calcula la divisón entre el resto*10 y el divisor
				beqz $a1,salida #si $a1 es igual a 0, va a la salida
				sub $a1,$a1,$a2 #a $a1 se le resta $a2
				bltz $a1,decimal2 #si $a1 es menor a 0, salta a calcular el decimal 2
				add $t1,$t1,1 # se le suma 1 a $t1, donde queda el primer decimal
			j div1
		
		decimal2:
		#en $t2 se guarda el segundo decimal
			add $a1,$a1,$a2 #como $a1 era negativo, se restaura su valor anterior
			add $t2, $zero,10 #a $t2 se le suma 10
			
			multi2:
			add $t3,$t3,$a1 #a $t3 se le suma lo de $a1
			subi $t2,$t2,1 #a $t2 se le resta 1
			beqz $t2,reset2 #si $t2 es igual a 0, salta a reset2
			j multi2
			
		reset2:
			add $a1,$zero,$t3	#a $a1 se le suma lo que había en $t3
			div2:
				#se calcula la división entre el segundo resto *10 y el divisor
				beqz $a1,salida #si $a1 es 0, va a la salida
				sub $a1,$a1,$a2 #a $a1 se le resta $a2
				bltz $a1,salida #si $a1 es menor que 0, quiere decir que ya se calcularon los 2 decimales y va a salida
				add $t2,$t2,1 #se le suma 1 a $t4
				j div2
				
				
		salida:
			#Se imprime mensaje para mostrar el resultado de la división
			li $v0, 4 #codigo 4 para imprimir un string
			la $a0, resultado #se imprime el mensaje de resultado
			syscall #llamada al sistema
			
			#Se muestra la parte entera
			li $v0, 1 #codigo 1 para imprimir un entero
			move $a0,$t0 #se mueve lo que había en $t0 a $a0
			syscall #llamada al sistema
			
			#Se imprime un punto, para indicar decimal
			li $v0, 4 #codigo 4 para imprimir un string
			la $a0, punto #se imprime un punto
			syscall #llamada al sistema
			
			#Se muestra el primer decimal
			li $v0, 1 #codigo 1 para imprimir un entero
			move $a0,$t1 #se mueve lo que había en $t1 a $a0
			syscall #llamada al sistema
			
			#Se muestra el segundo decimal
			li $v0, 1 #codigo 1 para imprimir un entero
			move $a0,$t2 #se mueve lo que había en $t2 a $a0
			syscall #llamada sl sistema
			
			j terminarPrograma
		
		
	terminarPrograma:
		#Se termina el programa
		li $v0, 10 #código 10 para terminar programa
		syscall #llamada al sistema
