.data
quatro:     .float 4.0
dois:       .float 2.0
zero_float: .float 0.0
msg_reais:  .asciiz "Raízes reais:\n"
msg_x1:     .asciiz "x1 = "
msg_x2:     .asciiz "\nx2 = "
msg_complexas: .asciiz "Raízes complexas:\n"
msg_real1:  .asciiz "Parte real = "
msg_imag1:  .asciiz ", Parte imag = "
msg_real2:  .asciiz "\nParte real = "
msg_imag2:  .asciiz ", Parte imag = "
erro_msg: .asciiz "Erro: a nao pode ser zero.\n"

.text
.globl main

main:
    # Carrega a=1.0, b=-4.0, c=3.0
    li a0, 1
    li a1, -4
    li a2, 3
    fcvt.s.w f0, a0     # f0 = a
    fcvt.s.w f1, a1 # f1 = float b
    fcvt.s.w f2, a2 # f2 = float c

    jal ra, baskara     # Chama baskara

    # Imprime raízes com base no retorno em a0
    li t0, 1
    beq a0, t0, imprime_reais
    li t0, 2
    beq a0, t0, imprime_complexas

    # Caso de erro
    li a7, 4
    la a0, erro_msg
    ecall
    j fim

imprime_reais:
    li a7, 4
    la a0, msg_reais
    ecall

    # Desempilha x1 e x2
    flw f1, 0(sp)
    flw f2, 4(sp)

    li a7, 4
    la a0, msg_x1
    ecall
    li a7, 2
    fmv.s fa0, f1
    ecall

    li a7, 4
    la a0, msg_x2
    ecall
    li a7, 2
    fmv.s fa0, f2
    ecall

    addi sp, sp, 8
    j fim

imprime_complexas:
    li a7, 4
    la a0, msg_complexas
    ecall

    # Desempilha as partes (real1, imag1, real2, imag2)
    flw f1, 0(sp)   # real1
    flw f2, 4(sp)   # imag1
    flw f3, 8(sp)   # real2
    flw f4, 12(sp)  # imag2

    # Imprime raiz 1
    li a7, 4
    la a0, msg_real1
    ecall
    li a7, 2
    fmv.s fa0, f1
    ecall

    li a7, 4
    la a0, msg_imag1
    ecall
    li a7, 2
    fmv.s fa0, f2
    ecall

    # Imprime raiz 2
    li a7, 4
    la a0, msg_real2
    ecall
    li a7, 2
    fmv.s fa0, f3
    ecall

    li a7, 4
    la a0, msg_imag2
    ecall
    li a7, 2
    fmv.s fa0, f4
    ecall

    addi sp, sp, 16
    j fim

fim:
    li a7, 10
    ecall
	
# -----------------------
# Função: int baskara(float a, float b, float c)
# Retorna:
#   a0 = 1 ? reais (empilha x1 e x2)
#   a0 = 2 ? complexas (empilha parte real + imag e parte real - imag)
#   a0 = 0 ? erro (a == 0)

baskara:
    # Entradas: f0 = a, f1 = b, f2 = c

    # Verifica se a == 0
    la t0, zero_float
    flw f3, 0(t0)           # f3 = 0.0
    feq.s t1, f0, f3
    bne t1, x0, erro        # se a == 0 ? erro

    # b^2
    fmul.s f4, f1, f1       # f4 = b^2

    # 4 * a * c
    la t0, quatro
    flw f5, 0(t0)           # f5 = 4.0
    fmul.s f6, f5, f0       # f6 = 4a
    fmul.s f7, f6, f2       # f7 = 4ac

    # delta = b^2 - 4ac
    fsub.s f8, f4, f7       # f8 = delta

    # Testa delta >= 0
    la t0, zero_float
    flw f3, 0(t0)           # f3 = 0.0
    fle.s t2, f3, f8        # if 0.0 <= delta
    beq t2, x0, complexas   # se delta < 0 ? complexas

    # delta >= 0: reais
    fsqrt.s f9, f8          # sqrt(delta)

    # 2a
    la t0, dois
    flw f10, 0(t0)
    fmul.s f11, f10, f0     # f11 = 2a

    # -b
    fneg.s f12, f1

    # x1 = (-b + sqrt(delta)) / 2a
    fadd.s f13, f12, f9
    fdiv.s f14, f13, f11

    # x2 = (-b - sqrt(delta)) / 2a
    fsub.s f15, f12, f9
    fdiv.s f16, f15, f11

    # Empilha x1, x2
    addi sp, sp, -8
    fsw f14, 0(sp)          # x1
    fsw f16, 4(sp)          # x2

    li a0, 1
    ret

complexas:
    # parte real = -b / 2a
    fneg.s f12, f1
    la t0, dois
    flw f10, 0(t0)
    fmul.s f11, f10, f0     # f11 = 2a
    fdiv.s f17, f12, f11    # f17 = parte real

    # sqrt(-delta)
    fneg.s f18, f8
    fsqrt.s f19, f18
    fdiv.s f20, f19, f11    # parte imaginária

    # Empilha: real, imag+, real, imag-
    addi sp, sp, -16
    fsw f17, 0(sp)         # real
    fsw f20, 4(sp)         # imag+
    fsw f17, 8(sp)         # real
    fneg.s f21, f20
    fsw f21, 12(sp)        # imag-

    li a0, 2
    ret

erro:
    li a0, 0
    ret
