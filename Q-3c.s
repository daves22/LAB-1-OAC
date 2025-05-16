.data
a:      .float 0.0
b:      .float 0.0
c:      .float 0.0

prompt_a: .asciz "Digite o valor de a: "
prompt_b: .asciz "Digite o valor de b: "
prompt_c: .asciz "Digite o valor de c: "
nl:       .asciz "\n"

erro_msg: .asciz "Erro! Não é equação do segundo grau!\n"
r1:       .asciz "R(1) = "
r2:       .asciz "R(2) = "
mais_i:   .asciz " + "
menos_i:  .asciz " - "
i:        .asciz " i\n"

.text
.globl main

main:
        # Reserva espaço na stack para 2 floats (8 bytes)
        addi sp, sp, -16
        
loop:
        # Leitura de a
        la a0, prompt_a
        li a7, 4
        ecall
        li a7, 6       # read_float
        ecall
        la t0, a
        fsw fa0, 0(t0)

        # Leitura de b
        la a0, prompt_b
        li a7, 4
        ecall
        li a7, 6
        ecall
        la t0, b
        fsw fa0, 0(t0)

        # Leitura de c
        la a0, prompt_c
        li a7, 4
        ecall
        li a7, 6
        ecall
        la t0, c
        fsw fa0, 0(t0)

        # Carrega a, b, c
        la t0, a
        flw fa0, 0(t0)
        la t0, b
        flw fa1, 0(t0)
        la t0, c
        flw fa2, 0(t0)

        jal ra, baskara
        jal ra, show

        j loop

# Função baskara
baskara:
        addi sp, sp, -16
        sw ra, 12(sp)

        # Verifica se a == 0
        fcvt.s.w ft0, zero
        feq.s t0, fa0, ft0
        bnez t0, erro

        # Calcula delta = b² - 4ac
        fmul.s ft1, fa1, fa1       # b²
        li t0, 4
        fcvt.s.w ft2, t0
        fmul.s ft2, ft2, fa0       # 4a
        fmul.s ft2, ft2, fa2       # 4ac
        fsub.s ft3, ft1, ft2       # delta

        # Verifica se delta < 0
        flt.s t0, ft3, ft0
        bnez t0, complexas

# Raízes reais
reais:
        fsqrt.s ft4, ft3           # sqrt(delta)
        fadd.s ft5, fa0, fa0       # 2a

        fneg.s ft6, fa1            # -b
        fadd.s ft6, ft6, ft4       # -b + sqrt(delta)
        fdiv.s ft6, ft6, ft5       # x1

        fneg.s ft7, fa1            # -b
        fsub.s ft7, ft7, ft4       # -b - sqrt(delta)
        fdiv.s ft7, ft7, ft5       # x2

        # Armazena na stack da main (16 bytes acima)
        fsw ft6, 16(sp)            # x1
        fsw ft7, 20(sp)            # x2

        li a0, 1
        j fim

# Raízes complexas
complexas:
        fabs.s ft3, ft3            # |delta|
        fsqrt.s ft7, ft3           # sqrt(|delta|)
        fadd.s ft5, fa0, fa0       # 2a

        fneg.s ft6, fa1            # -b
        fdiv.s ft6, ft6, ft5       # parte real

        fdiv.s ft7, ft7, ft5       # parte imag

        # Armazena na stack da main (16 bytes acima)
        fsw ft6, 16(sp)            # parte real
        fsw ft7, 20(sp)            # parte imag

        li a0, 2
        j fim

erro:
        li a0, 0

fim:
        lw ra, 12(sp)
        addi sp, sp, 16
        ret

# Função show
show:
        addi sp, sp, -16
        sw ra, 12(sp)
        sw a0, 8(sp)

        beqz a0, show_erro
        li t0, 1
        beq a0, t0, show_reais
        li t0, 2
        beq a0, t0, show_complexas
        j fim_show

show_reais:
        # Acessa valores da stack da main (16 bytes acima)
        flw ft0, 16(sp)    # x1
        flw ft1, 20(sp)    # x2

        # Mostra x1
        la a0, r1
        li a7, 4
        ecall
        fmv.s fa0, ft0
        li a7, 2
        ecall
        la a0, nl
        li a7, 4
        ecall

        # Mostra x2
        la a0, r2
        li a7, 4
        ecall
        fmv.s fa0, ft1
        li a7, 2
        ecall
        la a0, nl
        li a7, 4
        ecall
        j fim_show

show_complexas:
        # Acessa valores da stack da main (16 bytes acima)
        flw ft0, 16(sp)    # parte real
        flw ft1, 20(sp)    # parte imag

        # Mostra R(1) = real + imag i
        la a0, r1
        li a7, 4
        ecall
        fmv.s fa0, ft0
        li a7, 2
        ecall
        la a0, mais_i
        li a7, 4
        ecall
        fmv.s fa0, ft1
        li a7, 2
        ecall
        la a0, i
        li a7, 4
        ecall

        # Mostra R(2) = real - imag i
        la a0, r2
        li a7, 4
        ecall
        fmv.s fa0, ft0
        li a7, 2
        ecall
        la a0, menos_i
        li a7, 4
        ecall
        fmv.s fa0, ft1
        li a7, 2
        ecall
        la a0, i
        li a7, 4
        ecall
        j fim_show

show_erro:
        la a0, erro_msg
        li a7, 4
        ecall

fim_show:
        lw ra, 12(sp)
        lw a0, 8(sp)
        addi sp, sp, 16
        ret