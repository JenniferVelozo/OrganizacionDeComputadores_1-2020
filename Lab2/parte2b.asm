.data
	pedirNumero: .asciiz "Ingrese un numero entero positivo menor o igual a 12: " 
	resultado: .asciiz "El factorial es: "
.text
	#57 instrucciones
	#validación para ingresar un número mayor o igual a 0 y menor a 12 
	loop:
		li $v0, 4 #codigo 4 para imprimir un string
		la $a0, pedirNumero #se imprime un mensaje para ingresar el primer número
		syscall #llamada al sistema
	
		#Se obtiene el numero entero
		li $v0,5 #se pone v0 en 5 para recibir un entero
		syscall #llamada al sistema
		move $a1, $v0 #se mueve el contenido de v0 a a1
	
	bltz $a1,loop #si el valor ingresado es menor a cero
	bgt $a1,12,loop #si el valor ingresado es mayor a 12
	
	#se hace el llamado a la subrutina
	jal factorial
	#calculado el factorial, salta a mostrar el resultado final
	jal mostrarResultado
	
	#Subrutina para calcular factorial
	factorial:
		#En $s0 se guarda el resultado
		addi $sp,$sp,-4 # ajustar la pila para 1 elemento
		sw $s0, 0($sp) # guardar la dirección de retorno
		
		ble $a1,1,casoBase #si el valor es menor o igual 1, salta a casoBase
		beq $a1,2,casoBase2 #si el valor es 2, salta al casoBase2
		add $s1,$zero,$a1 #se copia lo de $a1 en $s1
		subi $s1, $s1,1 #se le resta 1 $s1
		add $s0, $zero,$a1 #se copia lo de $a1 en $s0
		#Se crea una copia de $a1 en $t0
		add $t0,$zero,$a1
		subi $t0,$t0,2 #se le resta 2 a $t0
		
		#Luego se tiene, por ejemplo para el factorial de a1=6:
		#$t0=4 (se le resta 2 a 6), $s1= 5, $s0=6 y en $s2=0, donde se va guardando el resultado temporal
		#de la multiplicación, que luego se copia a $s0 cuando $s1 llega a 0
		#Se va sumando lo de s0 a s2, luego se le resta 1 a s1
		#s1 llega a 0, entonces lo que quedó en s2 se pasa a s0 y en s1 se copia lo de t0
		#s2 se resetea y a t0 se le resta 1. Se repite este ciclo hasta que t0 llega a 0 y termina.
		#Se va acumulando lo de $s0 en $s2, ya que es donde va quedando el valor mayor y así se le resta 1 al menor ($s1) el cual va
		#decreciendo en 1, tomando menos tiempo en ejecución
		multiplicar:
			#se va multiplicando lo de $s0 por $s1, acumulando $s0 en $s2 y restando 1 a $s1
			add $s2, $s2,$s0 #a $s2 se le suma lo de $s0
			subi $s1,$s1,1 #se le resta 1 a $s1
			beqz $s1,copiar #si $s1 es igual a 0, salta a la etiqueta copiar
			j multiplicar

		copiar:
			#Como $s1 llegó a 0, entonces lo de $s2 se pasa a $s0 y
			#como $t0 inicia con 2 unidades menos, ahora se pasa lo de $t0 a $s1 y se le resta 1 a $t0
			#por lo que ahora se realiza la multiplicación nuevamante entre $s0 y $s1
			add $s0, $zero,$s2 #se copia el contenido de $s2 en $s0
			add $s1,$zero,$t0 #se copia el contenido de $t0 en $s1
			sub $s2,$s2,$s2 #$s2 se queda en 0
			subi $t0,$t0,1  #se le resta 1 a $t0
			#si sale, el resultado queda en $s0, ya que anteriormente se pasó lo de $s2 a este registro
			beq $t0,0, salida #si $t0 es igual a 0, salta a la etiqueta salida
			j multiplicar
		
		casoBase:
			#en caso de que el número ingresado sea menor o igual a 1, dando resultado 1
			addi $s0,$s0,1 #se suma 1 a $s0
			j salida #salta a la salida
		
		casoBase2:
			#en caso que el número ingresado sea 2, dando resultado 2
			addi $s0,$s0,2 #se le suma 2 a $s0
			j salida #salta a la salida
		salida:
			add $v1,$s0,$zero #se guarda en $v1 el resultado del factorial, para poder retornar
			
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
