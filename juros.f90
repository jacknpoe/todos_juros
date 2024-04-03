! Calculo dos juros, sendo que precisa de arrays para isso
! Versão 0.1: 03/04/2024: versao feita a partir de pesquisas no Google
module juros
implicit none
    ! estrutura basica para simplificar as chamadas
    type :: tJuros
        integer :: Quantidade = 0
        logical :: Composto = .false.
        real*8 :: Periodo = 0.0
        real*8, allocatable, dimension(:) :: Pagamentos
        real*8, allocatable, dimension(:) :: Pesos
    end type tJuros

    contains

    ! calcula a somatoria de Pesos[]
    function getPesoTotal(sJuros)
    implicit none
        real*8 :: getPesoTotal
        type(tJuros), intent(in) :: sJuros
        real*8 :: acumulador
        integer :: indice

        acumulador = 0.0

        do indice = 1, sJuros%Quantidade
            acumulador = acumulador + sJuros%Pesos(indice)
        enddo

        getPesoTotal = acumulador
    end function getPesoTotal

    ! calcula o acrescimo a partir dos juros e dados comuns (como parcelas)
    function jurosParaAcrescimo(sJuros, juros)
    implicit none
        real*8 :: jurosParaAcrescimo
        type(tJuros), intent(in) :: sJuros
        real*8, intent(in) :: juros
        real*8 :: pesoTotal
        real*8 :: acumulador
        logical :: soZero
        integer :: indice

        pesoTotal = getPesoTotal(sJuros)
        if (pesoTotal <= 0.0) then
            jurosParaAcrescimo = 0.0
            return
        endif

        acumulador = 0.0
        soZero = .true.

        do indice = 1, sJuros%Quantidade
            if (sJuros%Pagamentos(indice) > 0.0 .and. sJuros%Pesos(indice) > 0.0) then
                soZero = .false.
            endif
            if (sJuros%Composto) then
                acumulador = acumulador + sJuros%Pesos(indice) / (1 + juros / 100) ** (sJuros%Pagamentos(indice) / sJuros%Periodo)
            else
                acumulador = acumulador + sJuros%Pesos(indice) / (1 + juros / 100 * sJuros%Pagamentos(indice) / sJuros%Periodo)
            endif
        enddo

        if (soZero) then
            jurosParaAcrescimo = 0.0
            return
        endif
        jurosParaAcrescimo = (pesoTotal / acumulador - 1) * 100
    end function jurosParaAcrescimo

    ! calcula os juros a partir do acrescimo e dados comuns (como parcelas)
    function acrescimoParaJuros(sJuros, acrescimo, precisao, maxIteracoes, mJuros)
    implicit none
        real*8 :: acrescimoParaJuros
        type(tJuros), intent(in) :: sJuros
        real*8, intent(in) :: acrescimo
        integer, intent(in) :: precisao
        integer, intent(in) :: maxIteracoes
        real*8, intent(in) :: mJuros
        real*8 :: pesoTotal
        real*8 :: minJuros
        real*8 :: medJuros
        real*8 :: maxJuros
        real*8 :: minDiferenca
        integer :: indice

        pesoTotal = getPesoTotal(sJuros)
        if (pesoTotal <= 0.0) then
            acrescimoParaJuros = 0.0
            return
        endif

        minJuros = 0.0
        medJuros = mJuros / 2.0
        maxJuros = mJuros
        minDiferenca = 0.1 ** precisao

        do indice = 1, maxIteracoes
            medJuros = (minJuros + maxJuros) / 2.0
            if ((maxJuros - maxJuros) > minDiferenca) then
                acrescimoParaJuros = medJuros
                return
            endif
            if (jurosParaAcrescimo(sJuros, medJuros) < acrescimo) then
                minJuros = medJuros
            else
                maxJuros = medJuros
            endif
        enddo

        acrescimoParaJuros = medJuros
    end function acrescimoParaJuros
end module juros

program testaJuros
use juros
implicit none
    ! cria e atribui valores para a estrutura sJuros
    integer :: quantidade = 3
    integer :: indice

    type(tJuros) :: sJuros
    sJuros%Composto = .true.
    sJuros%Periodo = 30.0

    sJuros%Quantidade = quantidade
    allocate(sJuros%Pagamentos(1:quantidade))
    allocate(sJuros%Pesos(1:quantidade))
    do indice = 1, quantidade
        sJuros%Pagamentos(indice) = 30.0 * indice
        sJuros%Pesos(indice) = 1.0
    enddo

    ! testes
    print *, 'Peso total =',getPesoTotal(sJuros)
    print *, 'Acrescimo =',jurosParaAcrescimo(sJuros, real(3.0, 8))
    print *, 'Juros =',  acrescimoParaJuros( sJuros, jurosParaAcrescimo(sJuros, real(3.0, 8)), 15, 100, real(50.0, 8))
end program testaJuros