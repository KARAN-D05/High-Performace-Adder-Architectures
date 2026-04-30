! Fixed-Point Dot Product — Fortran 90 Implementation
! Q8.8 format: scale factor = 256 (2^8)
! Compile: gfortran -o dot_product dot_product.f90

program dot_product
    implicit none   ! force explicit declaration of all variables

    integer, parameter :: N         = 8
    integer, parameter :: SCALE     = 256   ! 2^8 — fixed-point scaling factor
    integer, parameter :: FRAC_BITS = 8

    real    :: A(N), B(N)           ! input vectors — real values
    integer :: A_fx(N), B_fx(N)    ! Q8.8 encoded integers
    integer :: i

    real        :: fp_result        ! floating-point dot product
    integer(8)  :: acc              ! 64-bit accumulator — sized to prevent overflow
    integer     :: fx_raw           ! raw Q8.8 result after shift
    real        :: fx_result        ! decoded fixed-point result
    real        :: error            ! precision loss percentage

    A = (/ 1.5, 2.25, 0.75, 3.0, 1.125, 2.5, 0.5, 1.75 /)
    B = (/ 2.0, 1.5,  3.25, 0.5, 2.75,  1.0, 3.5, 2.25 /)

    ! Encode: multiply by 256, round to nearest integer
    do i = 1, N
        A_fx(i) = nint(A(i) * real(SCALE))
        B_fx(i) = nint(B(i) * real(SCALE))
    end do

    ! --- METHOD 1: Naive floating-point ---
    fp_result = 0.0
    do i = 1, N
        fp_result = fp_result + A(i) * B(i)   ! ~2000 gates per multiply in hardware
    end do

    ! --- METHOD 2: Fixed-point Q8.8 ---
    acc = 0_8
    do i = 1, N
        ! Multiply two Q8.8 values → Q16.16 result, accumulate (~200 gates per multiply)
        acc = acc + int(A_fx(i), kind=8) * int(B_fx(i), kind=8)
    end do

    ! Right-shift by FRAC_BITS: Q16.16 → Q8.8. Free in hardware — just rewiring.
    fx_raw    = int(ishft(acc, -FRAC_BITS))
    fx_result = real(fx_raw) / real(SCALE)

    ! Overflow check — mirrors hardware status flag behaviour
    if (acc > 2147483647_8) print *, "WARNING: overflow — widen accumulator register"

    ! Results
    error = abs(fp_result - fx_result) / fp_result * 100.0

    print "(A, F10.6, A, I6)", "Floating-point result : ", fp_result, "  (gate cost ~", N*2000
    print "(A, F10.6, A, I6)", "Fixed-point result    : ", fx_result, "  (gate cost ~", N*200
    print "(A, F8.4, A)",      "Precision loss        : ", error, " %"
    print *,                   "Gate reduction        : ~10x"

end program dot_product
