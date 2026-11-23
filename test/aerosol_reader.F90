program aerosol_reader
  use cldj_cmn_mod, only : NAA, TITLAA, QAA, WAA, SAA, PAA, RAA, DAA, LWEPAR, JVN_
  use cldj_error_mod, only : CLDJ_SUCCESS
  use cldj_init_mod, only : INIT_CLDJ
  implicit none

  character(len=1024) :: source, scratch
  integer :: original_count, expanded_count, rc

  call get_command_argument(1, source)
  call get_command_argument(2, scratch)
  call load_table(source, rc)
  if (rc /= CLDJ_SUCCESS .or. NAA < 3) stop 1
  original_count = NAA
  expanded_count = max(75, original_count + 1)
  call write_fixture(expanded_count, .false.)
  call load_table(scratch, rc)
  if (rc /= CLDJ_SUCCESS .or. NAA /= expanded_count) stop 2
  if (size(QAA,2) /= expanded_count .or. size(PAA,3) /= expanded_count) stop 3
  call check_last_record

  call write_fixture(expanded_count, .true.)
  call load_table(scratch, rc)
  if (rc == CLDJ_SUCCESS .or. NAA /= expanded_count) stop 4
  call check_last_record

  call load_table(source, rc)
  if (rc /= CLDJ_SUCCESS .or. NAA /= original_count) stop 5
  if (size(QAA,2) /= original_count .or. size(PAA,3) /= original_count) stop 6

contains

  subroutine load_table(folder, status)
    character(len=*), intent(in) :: folder
    integer, intent(out) :: status
    character(len=6) :: titles(JVN_)
    integer :: j_count
    logical :: still_open
    call INIT_CLDJ(.false., trim(folder), 57, LWEPAR, titles, JVN_, &
                   1.05d0, .005d0, 18, 7, .33d0, 6, 1, .true., j_count, status)
    inquire(unit=8, opened=still_open)
    if (still_open) stop 7
  end subroutine load_table

  subroutine write_fixture(count, truncated)
    integer, intent(in) :: count
    logical, intent(in) :: truncated
    character(len=256) :: line, record(6)
    integer :: src, dest, row, j
    open(newunit=src, file=trim(source)//'/FJX_scat-aer.dat', status='old', action='read')
    open(newunit=dest, file=trim(scratch)//'/FJX_scat-aer.dat', status='replace', action='write')
    do row=1,3
      read(src, '(a)') line
      write(dest, '(a)') trim(line)
    enddo
    do j=1,original_count
      do row=1,size(record)
        read(src, '(a)') record(row)
        write(dest, '(a)') trim(record(row))
      enddo
    enddo
    close(src)
    do j=original_count+1,count
      write(dest, '(i4,a14,a)') j, ' Test aerosol ', trim(record(1)(19:))
      do row=2,size(record)
        if (truncated .and. j == count .and. row == size(record)) exit
        write(dest, '(a)') trim(record(row))
      enddo
    enddo
    close(dest)
  end subroutine write_fixture

  subroutine check_last_record
    if (TITLAA(expanded_count) /= 'Test aerosol') stop 8
    if (RAA(expanded_count) /= RAA(original_count) .or. DAA(expanded_count) /= DAA(original_count)) stop 9
    if (any(WAA(:,expanded_count) /= WAA(:,original_count))) stop 10
    if (any(QAA(:,expanded_count) /= QAA(:,original_count))) stop 11
    if (any(SAA(:,expanded_count) /= SAA(:,original_count))) stop 12
    if (any(PAA(:,:,expanded_count) /= PAA(:,:,original_count))) stop 13
  end subroutine check_last_record

end program aerosol_reader
