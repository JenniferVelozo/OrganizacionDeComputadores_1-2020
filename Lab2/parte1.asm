.data
	#Mensajes para el usuario
	pedirNumero1: .asciiz "Por favor ingrese el primer entero: "
	pedirNumero2: .asciiz "Por favor ingrese el segundo entero: "
	maximo: .asciiz "El máximo es: "
	
.text
	#38 instrucciones
	li $v0, 4 #codigo 4 para imprimir un string
	la $a0, pedirNumero1 #se imprime un mensaje para ingresar el primer número
	syscall #llamada al sistema
	
	#Se obtiene el primer número
	li $v0,5 #se pone v0 en 5 para recibir un entero
	syscall #llamada al sistema
	move $a1, $v0 #se mueve el contenido de v0 a a1, el primer número ingresado

	li $v0, 4 #codigo 4 para imprimir un string
	la $a0, pedirNumero2 #se imprime un mensaje para ingresar el segundo número
	syscall #llamada al sistema
	
	#Se obtiene el segundo número
	li $v0,5 #se pone v0 en 5 para recibir un entero
	syscall #llamada al sistema
	move $a2, $v0 #se mueve el contenido de v0 a a2, el segundo número ingresado

	#se hace el llamado a la subrutina
	jal mayor
	#se muestra el resultado por pantalla
	jal mostrarResultado
	
	#Subrutina para calcular número mayor
	mayor:
		addi $sp,$sp,-4 #ajustar la pila para 1 elemento
		sw $s0, 0($sp) #guardar la dirección de retorno	
		
		bge $a1,$a2,numero1Mayor #si el primer numero es igual o mayor al segundo numero
		bge $a2,$a1,numero2Mayor #si el segundo numero es igual o mayor al primer numero
		
		numero1Mayor:
			#En caso que el primer número sea el mayor
			add $s0,$zero,$a1 #se guarda el primer numero en $s0
			j salida #salta a la etiqueta de salida
		numero2Mayor:
			#En caso que el primer número sea el menor
			add $s0,$zero,$a2 #se guarda el segundo numero en $s0
		
		salida:
		add $v1,$s0,$zero #se guarda en $v1 el valor mayor, para poder retornar
			
		lw $s0, 0($sp) # restaura registro $s0 para el llamador
		addi $sp,$sp,4 # ajusta la pila para eliminar 1 campo
		
		jr $ra # salto de retorno a la rutina de llamada
	
	mostrarResultado:
		#Se muestra mensaje para mostrar el número mayor
		li $v0, 4 #codigo 4 para imprimir un string
		la $a0, maximo #se imprime el mensaje para indicar número mayor
		syscall #llamada al sistema
	
		#Se muestra el número mayor
		li $v0, 1 #codigo 1 para imprimir un entero
		move $a0,$v1 #se mueve lo que había en $v1 a $a0
		syscall #llamada al sistema	
		
	terminarPrograma:
		#Se termina el programa
		li $v0, 10 #código 10 para terminar programa
		syscall #llamada al sistema
	
	
