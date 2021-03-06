program sample
  use mod_variable
  use time_util
  implicit none
  integer, parameter :: &
    EPHM_TOC = 1,	EPHM_AF0 = 2,	EPHM_AF1 = 3,	EPHM_AF2 = 4, & ! line 1
    EPHM_IODE = 5,	EPHM_Crs = 6,	EPHM_d_n = 7,	EPHM_M0 = 8, & ! line 2
    EPHM_Cuc = 9,	EPHM_e = 10, EPHM_Cus = 11,	EPHM_sqrtA = 12, & ! line 3
    EPHM_TOE = 13, EPHM_Cic = 14,	EPHM_OMEGA0 = 15, EPHM_Cis = 16, & ! line 4
    EPHM_i0 = 17,	EPHM_Crc = 18,	EPHM_omega = 19,	EPHM_OMEGADOT= 20, & !line 5
    EPHM_IDOT = 21,	EPHM_CAonL2 = 22, EPHM_WEEK = 23,	EPHM_L2P = 24,	& ! line 6
    EPHM_acc = 25, EPHM_health = 26, EPHM_TGD = 27,	EPHM_IODC = 28,	& ! line 7
    EPHM_TOT = 29, EPHM_FIT = 30, EPHM_spare1 = 31, EPHM_spare2 = 32 ! line 8
  integer i, j, data_num, PRN
  real(8) ephm_data(8 * 4) ! １衛星のエフェメリスデータ
  real(8) Nav_data(4, 32) ! 4衛星のエフェメリスデータ
  integer year, month, day, hour, minute
  real(8) second
  open(10, file="data/1222040h.20n")

  ! ヘッダ部 ---------------------------------------
  ! 現時点では読み飛ばす
  !do i = 1, 8 ! RINEX 2.11
  do i = 1, 4 ! RINEX 2.10
    read(10, '()')
  end do
  ! -------------------------------------------------

  ! データ部 ----------------------------------------
  write(6, *) "Reading RINEX Nav. . ."
  do data_num = 1, 3
    ! エフェメリスデータ格納配列を初期化
    ephm_data(8 * 4) = 0.0
    ! １行ずつデータを読み込む
    read(10, '(I2,1X,I2.2,1X,I2,1X,I2,1X,I2,1X,I2,F5.1,3D19.12)') &
      PRN, year, month, day, hour, minute, second, &
      ephm_data(EPHM_AF0), ephm_data(EPHM_AF1), ephm_data(EPHM_AF2)
    GPS_sec = 0.0
    call utc_to_GPStime(year, month, day, hour, minute, second)
    ephm_data(EPHM_TOC) = GPS_sec
    read(10, '(3X, 4D19.12)') ephm_data(EPHM_IODE), ephm_data(EPHM_Crs), ephm_data(EPHM_d_n), &
      ephm_data(EPHM_M0)
    read(10, '(3X, 4D19.12)') ephm_data(EPHM_Cuc), ephm_data(EPHM_e), ephm_data(EPHM_Cus), &
      ephm_data(EPHM_sqrtA)
    read(10, '(3X, 4D19.12)') ephm_data(EPHM_TOE), ephm_data(EPHM_Cic), ephm_data(EPHM_OMEGA0), &
      ephm_data(EPHM_Cis)
    read(10, '(3X, 4D19.12)') ephm_data(EPHM_i0), ephm_data(EPHM_Crc), ephm_data(EPHM_omega), &
      ephm_data(EPHM_OMEGADOT)
    read(10, '(3X, 4D19.12)') ephm_data(EPHM_IDOT), ephm_data(EPHM_CAonL2), &
      ephm_data(EPHM_WEEK), ephm_data(EPHM_L2P)
    read(10, '(3X, 4D19.12)') ephm_data(EPHM_acc), ephm_data(EPHM_health), ephm_data(EPHM_TGD), &
      ephm_data(EPHM_IODC)
    read(10, '(3X, 4D19.12)') ephm_data(EPHM_TOT), ephm_data(EPHM_FIT), &
      ephm_data(EPHM_spare1), ephm_data(EPHM_spare2)
    ! 1衛星分のエフェメリスデータを格納
    do i = 1, 32
      Nav_data(data_num, i) = ephm_data(i)
    end do
  end do
  close(10)

  do i = 1, 3
    write(*, *) "------------------------------------------"
    do j = 1, 32
      write(*, *) Nav_data(i, j)

    end do
  end do




end program sample
