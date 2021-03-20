module time_util
  use mod_variable
  implicit none
contains
  subroutine julianday(Y, M, D, hh, mm, ss, MJD_now)
    ! Jurian Dayを計算
    implicit none
    DOUBLE PRECISION Y, M, D, hh, mm, ss, MJD, MJD_now
    Y = 2000.d0 + Y

    if (M == 1.d0 .or. M == 2.d0) then
      M = M + 12.d0
      Y = Y - 1.d0
    end if

    MJD = floor(365.25d0*Y) + floor(Y/400.d0) - floor(Y/100.d0) &
       + floor(30.59d0*(M-2.d0)) + D - 678912.d0 ! + 1721088.5
    ! write(*, *) " MJD = ", MJD

    MJD_now = MJD + (hh/24.d0 + mm/1440.d0 + ss/86400.d0)
  end subroutine julianday

! ======================================================================================

  subroutine date_to_wtime(year, month, day, hour, minute, ss, wt)
    ! 日時から週番号・秒への変換
    implicit none
    INTEGER year, month, day, hour, minute
    DOUBLE PRECISION Y, M, D, hh, mm, ss, MJD_now, delta_sec
    type(wtime), INTENT(OUT) :: wt

    MJD_now = 0.d0 ! 単位はday
    ! julianday計算用にdoubleに変換
    Y = dble(year)
    M = dble(month)
    D = dble(day)
    hh = dble(hour)
    mm = dble(minute)

    call julianday(Y, M, D, hh, mm, ss, MJD_now)

    delta_sec = (MJD_now - MJD_GPS_ZERO_EPOCH) * 86400.d0 ! 単位は秒
    wt%week = idint(delta_sec / WEEK_SEC)
    wt%sec = dmod(delta_sec, WEEK_SEC)
  end subroutine date_to_wtime

! ======================================================================================
  
end module time_util
