program waveform2dat
    use iso_c_binding
    implicit none

    ! Define the header type without the blk field
    type, bind(c) :: Header
        character(kind=c_char), dimension(4) :: Code        ! 4-character array
        real(c_double)                       :: orgintime   ! Origin time (8 bytes)
        integer(c_int16_t)                   :: ncom        ! Number of components (2 bytes)
        integer(c_int32_t)                   :: ndata       ! Number of data points (4 bytes)
        real(c_float)                        :: dt          ! Sampling interval (4 bytes)
    end type Header

    ! Declare variables
    type(Header) :: wh                      ! Waveform header
    real(c_float), allocatable :: wd(:,:)   ! Waveform data array
    integer :: i, j
    real(c_float) :: t
    character(len=4) :: CodeString    

    ! Open the binary file for unformatted stream access with appropriate endianness
    open(8, file='../data/seismicdata.bin', status='old', &
        form='unformatted', access='stream', convert='little_endian')

    ! Read the header
    read(8) wh

    ! Convert the Code array to a string
    CodeString = ''
    do i = 1, 4
        CodeString(i:i) = wh%Code(i)
    end do


    ! Print the header values for debugging
    print *, 'Code: ', trim(CodeString)
    print *, 'Origin Time:', wh%orgintime
    print *, 'Number of Components:', wh%ncom
    print *, 'Number of Data Points:', wh%ndata
    print *, 'Sampling Interval:', wh%dt

    ! Allocate the waveform data array based on header information
    allocate(wd(wh%ncom, wh%ndata))

    ! Read the waveform data
    read(8) wd

    ! Close the file
    close(8)

    ! Open an output file for plotting
    open(9, file='../data/seismogram.dat', status='unknown', form='formatted')

    ! Write time and waveform data to the output file
    do i = 1, wh%ndata
        t = (i - 1) * wh%dt
        write(9, *) t, (wd(j, i), j = 1, wh%ncom)
    end do

    ! Close the output file
    close(9)

    ! At this point, you can use external tools to plot 'seismogram.dat'

end program waveform2dat
