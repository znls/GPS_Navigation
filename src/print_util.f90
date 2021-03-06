module print_util
  use, intrinsic :: iso_fortran_env
  use exec_conditions
  use WGS84_constants
  use navigation_message
  implicit none
contains
  subroutine make_list_file()
    implicit none

    ! 使用局所領域
    enum, bind(c)
      enumerator :: Year = 1
      enumerator :: Month
      enumerator :: Day
      enumerator :: TimeDifference_min
      enumerator :: Hour
      enumerator :: Minute
      enumerator :: Second
      enumerator :: Millisecond
    end enum

    INTEGER :: value(8)

    ! 実行結果リストオープン
    open (20,  file=list_file, action='write', status='replace')

    ! 実行結果リストにヘッダを書き込む
    write(20, *) "  ____ ____  ____   ____    _    _     ____   ___  ____"
    write(20, *) " / ___|  _ \/ ___| / ___|  / \  | |   |  _ \ / _ \/ ___|"
    write(20, *) "| |  _| |_) \___ \| |     / _ \ | |   | |_) | | | \___ \"
    write(20, *) "| |_| |  __/ ___) | |___ / ___ \| |___|  __/| |_| |___) |"
    write(20, *) " \____|_|   |____/ \____/_/   \_\_____|_|    \___/|____/"
    write(20, *) "##### GPS Position Calculation Program #####"

    call date_and_time(values = value)
    write(20, '(A, I4, A, I2, A, I2, X, I2, A, I2, A, I2)') &
      "running date: ", value(Year), "-", value(Month), "-", value(Day), &
      value(Hour), ":", value(Minute), ":", value(Second)

    write(20, *) " ### Input File ###"
    write(20, *) "RINEX Navagation Message File : ", nav_msg_file
    write(20, *) ""
    write(20, *) " ### Execution Condition List ### "
    write(20, *) "Estimated Parameter Num: ", MAX_UNKNOWNS
    write(20, *) "MAX PRN : ", MAX_PRN
    write(20, *) "MAX Ephemeris Num : ", MAX_EPHMS
    write(20, *) "Expiration of Ephemeris[hour] : ", EPHEMERIS_EXPIRE
    write(20, *) "MAX Iteration : ", MAX_LOOP
    write(20, *) ""
    write(20, *) " ### Atmospheric Delay Flag ### "
    write(20, *) "Ionosphere : ", iono_flag
    write(20, *) "Troposphere : ", tropo_flag
    write(20, *) ""

    ! 実行結果リストクローズ
    close(20)

  end subroutine make_list_file

  subroutine print_nav_file_header()
    implicit none

    ! 実行結果リストオープン
    open (20,  file=list_file, action='write', status='old', position='append')

    write(20, *) ''
    write(20, *) '##### input Navigation Message #####'
    write(20, *) ''
    write(20, '(3X,A9,1X,F19.12,2X,A9,1X,D19.12,2X,A9,1X,D19.12,2X,A9,1X,D19.12)') &
      'alpha1:', ion_alpha(1), 'alpha2:', ion_alpha(2), 'alpha3:', ion_alpha(3), 'alpha4:', ion_alpha(4)
    write(20, '(3X,A9,1X,F19.12,2X,A9,1X,D19.12,2X,A9,1X,D19.12,2X,A9,1X,D19.12)') &
      'beta1:', ion_beta(1), 'beta2:', ion_beta(2), 'beta3:', ion_beta(3), 'beta4:', ion_beta(4)
    write(20, '(3X,A9,I6)') 'leap_sec:', leap_sec

    ! 実行結果リストクローズ
    close(20)

  end subroutine print_nav_file_header

  subroutine print_ephemeris_info(PRN)
    implicit none
    ! 引数詳細
    INTEGER, INTENT(IN) :: PRN

    ! 実行結果リストオープン
    open (20,  file=list_file, action='write', status='old', position='append')

    write(20, *) ''
    write(20, '(A,1X,I2)') 'PRN:', current_ephem(PRN)%PRN
    ! ----------- 1行目 ----------------------------------
    write(20, '(3X,A9,1X,F19.12,2X,A9,1X,D19.12,2X,A9,1X,D19.12,2X,A9,1X,D19.12)') &
      'TOC:', current_ephem(PRN)%TOC, 'AF0:', current_ephem(PRN)%AF0, 'AF1:', current_ephem(PRN)%AF1, &
      'AF2:', current_ephem(PRN)%AF2
    ! ----------- 2行目 ----------------------------------
    write(20, '(3X,A9,1X,D19.12,2X,A9,1X,D19.12,2X,A9,1X,D19.12,2X,A9,1X,D19.12)') &
      'IODE:', current_ephem(PRN)%IODE, 'Crs:', current_ephem(PRN)%Crs, 'delta_n:', current_ephem(PRN)%delta_n, &
      'M0: ', current_ephem(PRN)%M0
    ! ----------- 3行目 ----------------------------------
    write(20, '(3X,A9,1X,D19.12,2X,A9,1X,D19.12,2X,A9,1X,D19.12,2X,A9,1X,D19.12)') &
      'Cuc:', current_ephem(PRN)%Cuc, 'e:', current_ephem(PRN)%e,  'Cus:', current_ephem(PRN)%Cus, &
      'sqrtA:', current_ephem(PRN)%sqrtA
    ! ----------- 4行目 ----------------------------------
    write(20, '(3X,A9,1X,D19.12,2X,A9,1X,D19.12,2X,A9,1X,D19.12,2X,A9,1X,D19.12)') &
      'TOE:', current_ephem(PRN)%TOE, 'Cic:', current_ephem(PRN)%Cic, 'OMEGA0:', current_ephem(PRN)%LOMEGA0, &
      'Cis:', current_ephem(PRN)%Cis
    ! ----------- 5行目 ----------------------------------
    write(20, '(3X,A9,1X,D19.12,2X,A9,1X,D19.12,2X,A9,1X,D19.12,2X,A9,1X,D19.12)') &
      'i0:', current_ephem(PRN)%i0, 'Crc:', current_ephem(PRN)%Crc, 'omega:', current_ephem(PRN)%somega, &
      'OMEGADOT:', current_ephem(PRN)%OMEGA_DOT
    ! ----------- 6行目 ----------------------------------
    write(20, '(3X,A9,1X,D19.12,2X,A9,1X,D19.12,2X,A9,1X,D19.12,2X,A9,1X,D19.12)') &
      'IDOT:', current_ephem(PRN)%IDOT, 'CAonL2:', current_ephem(PRN)%CAonL2, 'WEEK:', current_ephem(PRN)%WEEK, &
      'L2P:', current_ephem(PRN)%L2P
    ! ----------- 7行目 ----------------------------------
    write(20, '(3X,A9,1X,D19.12,2X,A9,1X,D19.12,2X,A9,1X,D19.12,2X,A9,1X,D19.12)') &
      'acc:', current_ephem(PRN)%acc, 'health:', current_ephem(PRN)%health, 'TGD:', current_ephem(PRN)%TGD, &
      'IODC:', current_ephem(PRN)%IODC
    ! ----------- 8行目 ----------------------------------
    write(20, '(3X,A9,1X,D19.12,2X,A9,1X,D19.12)') &
      'TOT:', current_ephem(PRN)%TOT, 'Fit:', current_ephem(PRN)%Fit
    write(20, *) ''

    ! 実行結果リストクローズ
    close(20)

  end subroutine print_ephemeris_info

  subroutine print_csv_initialized()
    implicit none

    ! 使用局所領域
    CHARACTER(:), ALLOCATABLE  :: file_path
    CHARACTER(256)               :: char_PRN
    CHARACTER(1024)            :: csv_file_path_list(num_used_PRN)
    INTEGER                    :: i, unit_num

    ! 出力csvファイルパスを作成
    do i=1, num_used_PRN
      char_PRN = ""
      write(char_PRN, *) used_PRN_list(i)
      file_path = trim(tmp_dir) // "correction_param_" // trim(char_PRN) // ".csv"
      call StripSpaces(file_path)
      csv_file_path_list(i) = file_path

      ! csvヘッダ書き込み
      unit_num = i * 100
      open (unit_num,  file=csv_file_path_list(i), action='write', status='replace')
      write(unit_num, *) "PRN", "," , &
                        "reeceiver_epoch", ",", &
                         "iteration_num", ",", &
                         "receirver_pos_x", ",", &
                         "receiver_pos_y", ",", &
                         "receiver_pos_z", ",", &
                         "reciver_clock_bias", ",", &
                         "O-C", ",", &
                         "sat_pos_x", ",", &
                         "sat_pos_y", ",", &
                         "sat_pos_z", ",", &
                         "sat_clock_correction", ",", &
                         "iono_correction", ",", &
                         "tropo_correction", ","
      close(unit_num)
    end do

  end subroutine print_csv_initialized

  subroutine print_correction_data()
    implicit none
    ! 引数詳細


    ! 使用局所領域
    CHARACTER(1024) :: csv_file_path_list(num_used_PRN)
    INTEGER         :: epoch_num
    INTEGER         :: prn
    INTEGER         :: unit_num
    INTEGER         :: i, j
    CHARACTER(1024) :: linebuf

    ! 観測データ補正値をPRNごとにcsvファイルに書き出し
    do i=1, num_used_PRN
      ! csvファイルオープン
      unit_num = i * 100
      open (unit_num,  file=csv_file_path_list(i), action='write', status='old', position='append')

      ! 出力する衛星のPRNを取得
      prn = used_PRN_list(i)

      ! データを出力
      do epoch_num = 1, MAX_EPOCH
        do j = 1, MAX_LOOP
          write(linebuf, *) prn, ",", &
                            epoch_num, ",", &
                            j, ",", &
                            sol_for_print(1, epoch_num, j), ",", &
                            sol_for_print(2, epoch_num, j), ",", &
                            sol_for_print(3, epoch_num, j), ",", &
                            sol_for_print(4, epoch_num, j), ",", &
                            oc_for_print(epoch_num, prn, j), ",", &
                            sat_pos_for_print(1, epoch_num, prn, j), ",", &
                            sat_pos_for_print(2, epoch_num, prn, j), ",", &
                            sat_pos_for_print(3, epoch_num, prn, j), ",", &
                            sat_clock_for_print(epoch_num, prn, j), ",", &
                            iono_correction_for_print(epoch_num, prn, j), ",", &
                            tropo_correction_for_print(epoch_num, prn, j)
          call del_spaces(linebuf)
          write(unit_num, '(A)') trim(linebuf)
        end do
      end do
      ! csvファイルクローズ
      close(unit_num)

    end do



  end subroutine print_correction_data

  subroutine print_output_file_path(csv_file_path_list)
    implicit none

    ! 引数詳細
    CHARACTER(1024), INTENT(IN)  :: csv_file_path_list(num_used_PRN)

    ! 使用局所領域
    INTEGER :: i

    ! 出力csvファイルパスを実行結果リストに書き出し
    ! 実行結果リストオープン
    open (20,  file=list_file, action='write', status='old', position='append')

    write(20, *) "##### Output File Path#####"
    write(20, *) "Correction_OBS_Parameter file : ", trim(csv_file_path_list(1))
    do i = 2, num_used_PRN
      write(20, '(32X, A)') trim(csv_file_path_list(i))
    end do

    ! 実行結果リストクローズ
    close(20)
  end subroutine print_output_file_path

  subroutine StripSpaces(string)
    character(len=*) :: string
    integer :: stringLen
    integer :: last, actual

    stringLen = len (string)
    last = 1
    actual = 1

    do while (actual < stringLen)
        if (string(last:last) == ' ') then
            actual = actual + 1
            string(last:last) = string(actual:actual)
            string(actual:actual) = ' '
        else
            last = last + 1
            if (actual < last) &
                actual = last
        endif
    end do

    end subroutine

    subroutine del_spaces(s)
      character (*), intent (inout) :: s
      character (len=len(s)) tmp
      integer i, j
      j = 1
      do i = 1, len(s)
        if (s(i:i)==' ') cycle
        tmp(j:j) = s(i:i)
        j = j + 1
      end do
      s = tmp(1:j-1)
    end subroutine del_spaces


end module print_util
