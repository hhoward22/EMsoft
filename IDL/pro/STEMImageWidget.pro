;
; Copyright (c) 2013-2021, Marc De Graef Research Group/Carnegie Mellon University
; All rights reserved.
;
; Redistribution and use in source and binary forms, with or without modification, are 
; permitted provided that the following conditions are met:
;
;     - Redistributions of source code must retain the above copyright notice, this list 
;        of conditions and the following disclaimer.
;     - Redistributions in binary form must reproduce the above copyright notice, this 
;        list of conditions and the following disclaimer in the documentation and/or 
;        other materials provided with the distribution.
;     - Neither the names of Marc De Graef, Carnegie Mellon University nor the names 
;        of its contributors may be used to endorse or promote products derived from 
;        this software without specific prior written permission.
;
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
; SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
; CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
; OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE 
; USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
; ###################################################################
;--------------------------------------------------------------------------
; CTEMsoft2013:STEMImageWidget.pro
;--------------------------------------------------------------------------
;
; PROGRAM: STEMImageWidget.pro
;
;> @author Marc De Graef, Carnegie Mellon University
;
;> @brief Create the image (BF-HAADF) widget
;
;> @date 06/13/13 MDG 1.0 first attempt 
;--------------------------------------------------------------------------

pro STEMImageWidget,dummy
;
;------------------------------------------------------------
; common blocks
common STEM_widget_common, widget_s
common STEM_data_common, data
common fontstrings, fontstr, fontstrlarge, fontstrsmall


;------------------------------------------------------------
; create the top level widget
widget_s.imagebase = WIDGET_BASE(TITLE='BF / HAADF Image Display', $
                        /COLUMN, $
                        XSIZE=max([542,data.datadims[0]*2+30]), $
                        /ALIGN_CENTER, $
			/TLB_MOVE_EVENTS, $
			EVENT_PRO='STEMImageWidget_event', $
                        XOFFSET=data.imagexlocation, $
                        YOFFSET=data.imageylocation)

;------------------------------------------------------------
; create the various blocks
; block 1 contains the drawing windows
block1 = WIDGET_BASE(widget_s.imagebase, $
			/FRAME, $
			/ROW)

;------------------------------------------------------------
block1a = WIDGET_BASE(block1, $
			/FRAME, $
			/ALIGN_CENTER, $
			/COLUMN)

label1 = WIDGET_LABEL(block1a, $
			VALUE='BF Image', $
			FONT=fontstrlarge, $
			XSIZE=100, $
			YSIZE=30, $
			/ALIGN_CENTER)

widget_s.BFdraw = WIDGET_DRAW(block1a, $
			COLOR_MODEL=2, $
			RETAIN=2, $
			/BUTTON_EVENTS, $
			EVENT_PRO='STEMImageWidget_event', $
			UVALUE = 'DRAWCBED', $
			TOOLTIP='Click on a point in the BF image to display the corresponding CBED pattern.', $
			XSIZE=data.datadims[0], $
			YSIZE=data.datadims[1])

block2a = WIDGET_BASE(block1a, $
			/FRAME, $
			/ROW)

label1 = WIDGET_LABEL(block2a, $
			VALUE='min/max', $
			FONT=fontstr, $
			XSIZE=75, $
			YSIZE=30, $
			/ALIGN_LEFT)

widget_s.BFmin= WIDGET_TEXT(block2a, $
			VALUE=string(data.BFmin,format="(F)"),$
			XSIZE=10, $
			/ALIGN_LEFT)

widget_s.BFmax= WIDGET_TEXT(block2a, $
			VALUE=string(data.BFmax,format="(F)"),$
			XSIZE=10, $
			/ALIGN_LEFT)


;------------------------------------------------------------
block1b = WIDGET_BASE(block1, $
			/FRAME, $
			/COLUMN)

label1 = WIDGET_LABEL(block1b, $
			VALUE='HAADF/DF Image', $
			FONT=fontstrlarge, $
			XSIZE=175, $
			YSIZE=30, $
			/ALIGN_CENTER)

widget_s.HAADFdraw = WIDGET_DRAW(block1b, $
			COLOR_MODEL=2, $
			RETAIN=2, $
			XSIZE=data.datadims[0], $
			YSIZE=data.datadims[1])


block2b = WIDGET_BASE(block1b, $
			/FRAME, $
			/ROW)

label1 = WIDGET_LABEL(block2b, $
			VALUE='min/max', $
			FONT=fontstr, $
			XSIZE=75, $
			YSIZE=30, $
			/ALIGN_LEFT)

widget_s.HAADFmin= WIDGET_TEXT(block2b, $
			VALUE=string(data.HAADFmin,format="(F)"),$
			XSIZE=10, $
			/ALIGN_LEFT)

widget_s.HAADFmax= WIDGET_TEXT(block2b, $
			VALUE=string(data.HAADFmax,format="(F)"),$
			XSIZE=10, $
			/ALIGN_LEFT)

;------------------------------------------------------------
; block 2 contains the button groups and save button
block2 = WIDGET_BASE(widget_s.imagebase, $
			/FRAME, $
			/ROW)

vals = ['Off','On']
widget_s.imagelegendbgroup = CW_BGROUP(block2, $
			vals, $
			/ROW, $
			/EXCLUSIVE, $
			/NO_RELEASE, $
			LABEL_LEFT = 'Scale Bar', $
			/FRAME, $
                        EVENT_FUNC='STEMevent', $
			UVALUE='IMAGELEGEND', $
			SET_VALUE=data.imagelegend)

vals = ['jpeg','tiff','bmp']
widget_s.imageformatbgroup = CW_BGROUP(block2, $
			vals, $
			/ROW, $
			/EXCLUSIVE, $
			/NO_RELEASE, $
			LABEL_LEFT = 'File Format', $
			/FRAME, $
                        EVENT_FUNC='STEMevent', $
			UVALUE='IMAGEFORMAT', $
			SET_VALUE=data.imageformat)

; and, finally, a save and a close button
widget_s.saveimage = WIDGET_BUTTON(block2, $
			VALUE='Save', $
			/NO_RELEASE, $
                        EVENT_PRO='STEMImageWidget_event', $
			UVALUE='SAVEIMAGE', $
			/ALIGN_RIGHT)

; the following option looks for a series of files with name
; of the form name__####.data, applies the same image computation 
; to each file (using the current program settings), and stores
; the images in jpeg or other format so that the user can
; subsequently generate a movie or a grid of images without having
; to manually load each file ...
widget_s.doseries = WIDGET_BUTTON(block2, $
			VALUE='Series', $
			/NO_RELEASE, $
                        EVENT_PRO='STEMImageWidget_event', $
			UVALUE='DOSERIES', $
			/ALIGN_RIGHT)

widget_s.closeimage = WIDGET_BUTTON(block2, $
			VALUE='Close', $
			/NO_RELEASE, $
                        EVENT_PRO='STEMImageWidget_event', $
			UVALUE='CLOSEIMAGE', $
			/ALIGN_RIGHT)




;------------------------------------------------------------
; realize the widget structure
WIDGET_CONTROL,widget_s.imagebase,/REALIZE

; realize the draw widgets
WIDGET_CONTROL, widget_s.BFdraw, GET_VALUE=drawID
widget_s.BFdrawID = drawID
WIDGET_CONTROL, widget_s.HAADFdraw, GET_VALUE=drawID
widget_s.HAADFdrawID = drawID

; and hand over control to the xmanager
XMANAGER,"STEMImageWidget",widget_s.imagebase,/NO_BLOCK

end

