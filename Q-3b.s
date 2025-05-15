        .data
a:      .float 5.0
b:      .float -5.0
c:      .float 6.0

msg:    .asciz "Retorno: "
nl:     .asciz "\n"
erro_msg: .asciz "Erro! Não é equação do segundo grau!\n"

r1:     .asciz "R(1) = "
r2:     .asciz "R(2) = "
mais_i: .asciz " + "
menos_i:.asciz " - "
i:      .asciz " i\n"

        .text
        .globl main

main:
        # carrega constantes em fa0-fa2
        la   t0, a
        flw  fa0, 0(t0)          # a
        la   t0, b
        flw  fa1, 0(t0)          # b
        la   t0, c
        flw  fa2, 0(t0)          # c

        jal  ra, baskara         # chama função
        mv   a0, a0              # tipo retornado em a0
        jal  ra, show            # mostra as raízes

        li   a7, 10              # exit
        ecall


        .globl baskara
baskara:
        addi sp, sp, -12
        sw   ra, 8(sp)

        # ft0 ← 0,0
        fcvt.s.w ft0, zero

        # se a == 0  → erro
        feq.s t0, fa0, ft0
        bnez  t0, erro

        # delta = b² − 4ac
        fmul.s ft1, fa1, fa1         # b²
        li    t0, 4
        fcvt.s.w ft2, t0             # 4.0
        fmul.s ft2, ft2, fa0         # 4a
        fmul.s ft2, ft2, fa2         # 4ac
        fsub.s ft3, ft1, ft2         # Δ

        # delta < 0 ?
        flt.s t0, ft3, ft0
        bnez  t0, complexas

######## raízes reais 
reais:
        fsqrt.s ft4, ft3             # sqrt(delta)
        fadd.s  ft5, fa0, fa0        # 2a   

        fneg.s ft6, fa1              # -b
        fadd.s ft6, ft6, ft4         # -b + sqrt(delta)
        fdiv.s ft6, ft6, ft5         # x1

        fneg.s ft7, fa1
        fsub.s ft7, ft7, ft4         # -b - sqrt(delta)
        fdiv.s ft7, ft7, ft5         # x2

        fsw   ft7, 0(sp)             # empilha x2
        fsw   ft6, 4(sp)             # empilha x1
        li    a0, 1
        j     fim

######## raízes complexas
complexas:
        fneg.s ft3, ft3              # |delta|
        fsqrt.s ft7, ft3             # sqrt(|delta|)
        fadd.s ft5, fa0, fa0         # 2a

        # parte real = -b / (2a)
        fneg.s ft6, fa1
        fdiv.s ft6, ft6, ft5

        # parte imag = sqrt(|delta|) / (2a)
        fdiv.s ft7, ft7, ft5

        fsw   ft7, 0(sp)             # imag
        fsw   ft6, 4(sp)             # real
        li    a0, 2
        j     fim

erro:
        li    a0, 0

fim:
        lw   ra, 8(sp)
        addi sp, sp, 12
        ret

        .globl show
show:
        # tipo em a0
        addi sp, sp, -8
        sw   ra, 4(sp)
        sw   a0, 0(sp)

        li   t1, 1
        beq  a0, t1, show_reais
        li   t1, 2
        beq  a0, t1, show_complexas
        j    show_erro

show_reais:
        # desempilha x1 e x2
        addi sp, sp, -8
        flw  ft6, 4(sp)
        flw  ft7, 0(sp)
        addi sp, sp, 8

        # R(1) = 
        la   a0, r1
        li   a7, 4
        ecall

        fmv.s fa0, ft6
        li   a7, 2
        ecall

        # \n
        la   a0, nl
        li   a7, 4
        ecall

        # R(2) = 
        la   a0, r2
        li   a7, 4
        ecall

        fmv.s fa0, ft7
        li   a7, 2
        ecall

        la   a0, nl
        li   a7, 4
        ecall

        j fim_show

show_complexas:
        # desempilha real e imag
        addi sp, sp, -8
        flw  ft6, 4(sp)    # real
        flw  ft7, 0(sp)    # imag
        addi sp, sp, 8

        # R(1) = real + imag i
        la   a0, r1
        li   a7, 4
        ecall

        fmv.s fa0, ft6
        li   a7, 2
        ecall

        la   a0, mais_i
        li   a7, 4
        ecall

        fmv.s fa0, ft7
        li   a7, 2
        ecall

        la   a0, i
        li   a7, 4
        ecall

        # R(2) = real - imag i
        la   a0, r2
        li   a7, 4
        ecall

        fmv.s fa0, ft6
        li   a7, 2
        ecall

        la   a0, menos_i
        li   a7, 4
        ecall

        fmv.s fa0, ft7
        li   a7, 2
        ecall

        la   a0, i
        li   a7, 4
        ecall

        j fim_show

show_erro:
        la   a0, erro_msg
        li   a7, 4
        ecall

fim_show:
        lw   ra, 4(sp)
        lw   a0, 0(sp)
        addi sp, sp, 8
        ret
