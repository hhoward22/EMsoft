! ###################################################################
! Copyright (c) 2016-2021, Marc De Graef Research Group/Carnegie Mellon University
! All rights reserved.
!
! Redistribution and use in source and binary forms, with or without modification, are
! permitted provided that the following conditions are met:
!
!     - Redistributions of source code must retain the above copyright notice, this list
!        of conditions and the following disclaimer.
!     - Redistributions in binary form must reproduce the above copyright notice, this
!        list of conditions and the following disclaimer in the documentation and/or
!        other materials provided with the distribution.
!     - Neither the names of Marc De Graef, Carnegie Mellon University nor the names
!        of its contributors may be used to endorse or promote products derived from
!        this software without specific prior written permission.
!
! THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
! AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
! IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
! ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
! LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
! DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
! SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
! CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
! OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
! USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
! ###################################################################

!--------------------------------------------------------------------------
! EMsoft:HDFdoubleTest.f90
!--------------------------------------------------------------------------
!
! MODULE: HDFdoubleTest
!
!> @author Marc De Graef, Carnegie Mellon University
!
!> @brief test module for writing and reading of real(dbl) to/from HDF5 files
!
!> @date 10/29/16   MDG 1.0 original
!--------------------------------------------------------------------------

module HDFdoubleTest

use stringconstants

contains 

subroutine HDFdoubleExecuteTest(res) &
           bind(c, name='HDFdoubleExecuteTest')    ! this routine is callable from a C/C++ program
!DEC$ ATTRIBUTES DLLEXPORT :: HDFdoubleExecuteTest

use,INTRINSIC :: ISO_C_BINDING
use local
use HDF5
use typedefs
use HDFsupport

IMPLICIT NONE

integer(C_INT32_T),INTENT(OUT)  :: res

character(fnlen)                :: HDFfilename, tmppath, groupname, dataset, textfile

integer(kind=irg)               :: i1, i2, i3, i4, dim1, dim2, dim3, dim4, hdferr, isum 
real(kind=dbl)                  :: dval, dval_save
integer(HSIZE_T)                :: dims1(1), dims2(2), dims3(3), dims4(4)
real(kind=dbl),allocatable      :: darr1(:), darr2(:,:), darr3(:,:,:), darr4(:,:,:,:)
real(kind=dbl),allocatable      :: darr1_save(:), darr2_save(:,:), darr3_save(:,:,:), darr4_save(:,:,:,:)

type(HDFobjectStackType)        :: HDF_head
character(len=1)                :: EMsoftnativedelimiter


!====================================
! generate the real arrays
dim1 = 5
dim2 = 10
dim3 = 15
dim4 = 20

ALLOCATE (darr1(dim1))
ALLOCATE (darr2(dim1,dim2))
ALLOCATE (darr3(dim1,dim2,dim3))
ALLOCATE (darr4(dim1,dim2,dim3,dim4))

dval = 123.D0

do i1=1,dim1
  darr1(i1) = dble(i1)
  do i2=1,dim2
    darr2(i1,i2) = dble(i1 * i2)
    do i3=1,dim3
      darr3(i1,i2,i3) = dble(i1 * i2 * i3)
      do i4=1,dim4
        darr4(i1,i2,i3,i4) = dble(i1 * i2 * i3 * i4)
      end do
    end do
  end do
end do

ALLOCATE (darr1_save(dim1))
ALLOCATE (darr2_save(dim1,dim2))
ALLOCATE (darr3_save(dim1,dim2,dim3))
ALLOCATE (darr4_save(dim1,dim2,dim3,dim4))

dval_save = dval
darr1_save = darr1
darr2_save = darr2
darr3_save = darr3
darr4_save = darr4

!====================================
! nullify the push/pop stack pointer
nullify(HDF_head%next)

! determine the pathname delimiter character
EMsoftnativedelimiter = EMsoft_getEMsoftnativedelimiter()

! get the location of the Temporary folder inside the Build folder (it always exists)
tmppath = EMsoft_getEMsofttestpath()

! initialize the fortran HDF interface
CALL h5open_EMsoft(hdferr)

! create and open the test file
HDFfilename = trim(tmppath)//EMsoftnativedelimiter//'HDFtest_double.h5'

write(*,*) 'writing filename = <'//trim(HDFfilename)//'>, has length ',len(trim(HDFfilename))
write (*,*) 'cstring : <'//cstringify(HDFfilename)//'> has length ',len(cstringify(HDFfilename))

hdferr =  HDF_createFile(HDFfilename, HDF_head)
if (hdferr.ne.0) then
  res = 1
  return
end if

! write the double and double arrays to the file
dataset = SC_doubleType
hdferr = HDF_writeDatasetDouble(dataset, dval, HDF_head)
if (hdferr.ne.0) then
  res = 2
  return
end if

dataset = SC_double1D
hdferr = HDF_writeDatasetDoubleArray1D(dataset, darr1, dim1, HDF_head)
if (hdferr.ne.0) then
  res = 3
  return
end if

dataset = SC_double2D
hdferr = HDF_writeDatasetDoubleArray2D(dataset, darr2, dim1, dim2, HDF_head)
if (hdferr.ne.0) then
  res = 4
  return
end if

dataset = SC_double3D
hdferr = HDF_writeDatasetDoubleArray3D(dataset, darr3, dim1, dim2, dim3, HDF_head)
if (hdferr.ne.0) then
  res = 5
  return
end if

dataset = SC_double4D
hdferr = HDF_writeDatasetDoubleArray4D(dataset, darr4, dim1, dim2, dim3, dim4, HDF_head)
if (hdferr.ne.0) then
  res = 6
  return
end if

call HDF_pop(HDF_head,.TRUE.)

! and close the fortran hdf interface
call h5close_EMsoft(hdferr)
!====================================


!====================================
! deallocate the integer arrays (they will be recreated upon reading)
dval = 0.D0
deallocate( darr1, darr2, darr3, darr4)
!====================================

!====================================
! next, we read the data sets from the HDF5 file
! nullify the push/pop stack pointer
nullify(HDF_head%next)

! initialize the fortran HDF interface
CALL h5open_EMsoft(hdferr)

! open the test file
HDFfilename = trim(tmppath)//EMsoftnativedelimiter//'HDFtest_double.h5'

write(*,*) 'reading filename = <'//trim(HDFfilename)//'>, has length ',len(trim(HDFfilename))
write (*,*) 'cstring : <'//cstringify(HDFfilename)//'> has length ',len(cstringify(HDFfilename))

hdferr =  HDF_openFile(HDFfilename, HDF_head)
if (hdferr.ne.0) then
  res = 7
  return
end if

! read the integer and arrays
dataset = SC_doubleType
call HDF_readDatasetDouble(dataset, HDF_head, hdferr, dval)
if (hdferr.ne.0) then
  res = 8
  return
end if

dataset = SC_double1D
call HDF_readDatasetDoubleArray1D(dataset, dims1, HDF_head, hdferr, darr1)
if (hdferr.ne.0) then
  res = 9
  return
end if

dataset = SC_double2D
call HDF_readDatasetDoubleArray2D(dataset, dims2, HDF_head, hdferr, darr2)
if (hdferr.ne.0) then
  res = 10 
  return
end if

dataset = SC_double3D
call HDF_readDatasetDoubleArray3D(dataset, dims3, HDF_head, hdferr, darr3)
if (hdferr.ne.0) then
  res = 11
  return
end if

dataset = SC_double4D
call HDF_readDatasetDoubleArray4D(dataset, dims4, HDF_head, hdferr, darr4)
if (hdferr.ne.0) then
  res = 12
  return
end if

call HDF_pop(HDF_head,.TRUE.)

! and close the fortran hdf interface
call h5close_EMsoft(hdferr)
!====================================


!====================================
! compare the entries with the stored values

isum = 20
if (dval.ne.dval_save) isum =  isum+1
if (sum(darr1-darr1_save).ne.0.D0) isum = isum + 2
if (sum(darr2-darr2_save).ne.0.D0) isum = isum + 4
if (sum(darr3-darr3_save).ne.0.D0) isum = isum + 8
if (sum(darr4-darr4_save).ne.0.D0) isum = isum + 16

if (isum.eq.20) then
  res = 0
else
  res = isum
end if
!====================================

end subroutine HDFdoubleExecuteTest


end module HDFdoubleTest
