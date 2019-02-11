! Copyright (C) 2011
! Free Software Foundation, Inc.

! This file is part of the gtk-fortran GTK+ Fortran Interface library.

! This is free software; you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation; either version 3, or (at your option)
! any later version.

! This software is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
! GNU General Public License for more details.

! Under Section 7 of GPL version 3, you are granted additional
! permissions described in the GCC Runtime Library Exception, version
! 3.1, as published by the Free Software Foundation.

! You should have received a copy of the GNU General Public License along with
! this program; see the files COPYING3 and COPYING.RUNTIME respectively.
! If not, see <http://www.gnu.org/licenses/>.
!
! Contributed by James Tappin
! Last modification: 12-31-2012

!!$T Template file for gtk-hl-dialog.f90.
!!$T  Make edits to this file, and keep them identical between the
!!$T  GTK2 & GTK3 branches.

!!$T Lines to appear only in specific versions should be prefixed by
!!$T !!$<lib><op><ver>!
!!$T Where <lib> is GTK or GLIB, <op> is one of < > <= >=
!!$T and <ver> is the version boundary, e.g. !!$GTK<=2.24! to include
!!$T the line in GTK+ version 2.24 and higher. 
!!$T The mk_gtk_hl.pl script should be used to generate the source file.

!*
! Dialogue
module gtk_hl_dialog
  ! The message dialogue provided is here because, the built-in message
  ! dialogue GtkMessageDialog cannot be created without calling variadic
  ! functions which are not compatible with Fortran, therefore this is
  ! based around the plain GtkDialog family.
  !
  ! There are two functions provided, one; hl_gtk_message_dialog_new,
  ! just creates a dialogue and the other; hl_gtk_message_dialog_show,
  ! creates the dialogue and also displays it and returns the response.
  ! Unless you need to add other non-standard buttons to the dialogue
  ! it is easier to use  hl_gtk_message_dialog_show.
  !/

  use gtk_sup
  use iso_c_binding
  use iso_fortran_env, only: error_unit

  ! autogenerated use's
  use gtk, only: gtk_about_dialog_new, gtk_about_dialog_set_artists, &
       & gtk_about_dialog_set_authors, gtk_about_dialog_set_comments, &
       & gtk_about_dialog_set_copyright, gtk_about_dialog_set_documenters, &
       & gtk_about_dialog_set_license, gtk_about_dialog_set_program_name, &
       & gtk_about_dialog_set_translator_credits, &
       & gtk_about_dialog_set_version, gtk_about_dialog_set_website, &
       & gtk_about_dialog_set_website_label, gtk_box_pack_start, &
!!$GTK< 3.0!       & gtk_hbox_new, gtk_vbox_new, &
!!$GTK>=3.0!       & gtk_box_new, gtk_about_dialog_set_license_type, &
       & gtk_dialog_add_button, gtk_dialog_get_content_area, gtk_dialog_new, &
       & gtk_dialog_run, gtk_image_new_from_stock, gtk_label_new, &
       & gtk_label_set_markup, gtk_widget_destroy, gtk_widget_show_all, &
       & gtk_window_set_destroy_with_parent, gtk_window_set_modal, &
       & gtk_window_set_title, gtk_window_set_transient_for, TRUE, &
       & GTK_RESPONSE_NONE, GTK_RESPONSE_OK, GTK_RESPONSE_CANCEL, &
       & GTK_RESPONSE_CLOSE, GTK_RESPONSE_YES, GTK_RESPONSE_NO, &
       & GTK_ICON_SIZE_DIALOG, GTK_MESSAGE_INFO, GTK_MESSAGE_WARNING, &
       & GTK_MESSAGE_QUESTION, GTK_MESSAGE_ERROR, GTK_MESSAGE_OTHER, &
       & GTK_BUTTONS_NONE, GTK_BUTTONS_OK, GTK_BUTTONS_CLOSE, &
!!$GTK>=3.0!       & GTK_ORIENTATION_HORIZONTAL,  GTK_ORIENTATION_VERTICAL, &
!!$GTK>=3.0!       & GTK_LICENSE_GPL_3_0, &
       & GTK_BUTTONS_CANCEL, GTK_BUTTONS_YES_NO, GTK_BUTTONS_OK_CANCEL


  implicit none

contains

  !+
  function hl_gtk_message_dialog_new(message, button_set, title, type, &
       & parent) result(dialog)

    type(c_ptr) :: dialog
    character(len=*), dimension(:), intent(in) :: message
    integer(kind=c_int), intent(in) :: button_set
    character(kind=c_char), dimension(*), intent(in), optional :: title
    integer(kind=c_int), intent(in), optional :: type
    type(c_ptr), intent(in), optional :: parent

    ! A DIY version of the message dialogue, needed because both creators
    ! for the built in one are variadic and so not callable from Fortran.
    !
    ! MESSAGE: string(n): required: The message to display. Since this is
    ! 		a string array, the C_NULL_CHAR terminations are provided
    ! 		internally
    ! BUTTON_SET: integer: required: The set of buttons to display
    ! TITLE: string: optional: Title for the window.
    ! TYPE: c_int: optional: Message type (a GTK_MESSAGE_ value)
    ! PARENT: c_ptr: optional: An optional parent for the dialogue.
    !-

    type(c_ptr) :: content, junk, hb, vb
    integer :: i
    integer(kind=c_int) :: itype

    ! Create the dialog window and make it modal.

    dialog=gtk_dialog_new()
    call gtk_window_set_modal(dialog, TRUE)
    if (present(title)) call gtk_window_set_title(dialog, title)

    if (present(parent)) then
       call gtk_window_set_transient_for(dialog, parent)
       call gtk_window_set_destroy_with_parent(dialog, TRUE)
    end if

    ! Get the content area and put the message in it.
    content = gtk_dialog_get_content_area(dialog)
    if (present(type)) then
       itype = type
    else if (button_set == GTK_BUTTONS_YES_NO) then
       itype = GTK_MESSAGE_QUESTION
    else
       itype = GTK_MESSAGE_OTHER
    end if

    if (itype /= GTK_MESSAGE_OTHER) then
!!$GTK< 3.0!       hb = gtk_hbox_new(FALSE, 0_c_int)
!!$GTK>=3.0!       hb = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0_c_int)
       call gtk_box_pack_start(content, hb, TRUE, TRUE, 0_c_int)
       select case (itype)
       case (GTK_MESSAGE_ERROR)
          junk = gtk_image_new_from_stock(GTK_STOCK_DIALOG_ERROR, &
               & GTK_ICON_SIZE_DIALOG)
       case (GTK_MESSAGE_WARNING)
          junk = gtk_image_new_from_stock(GTK_STOCK_DIALOG_WARNING, &
               & GTK_ICON_SIZE_DIALOG)
       case (GTK_MESSAGE_INFO)
          junk = gtk_image_new_from_stock(GTK_STOCK_DIALOG_INFO, &
               & GTK_ICON_SIZE_DIALOG)
       case (GTK_MESSAGE_QUESTION)
          junk = gtk_image_new_from_stock(GTK_STOCK_DIALOG_QUESTION, &
               & GTK_ICON_SIZE_DIALOG)
       case default
          junk=C_NULL_PTR
       end select
       if (c_associated(junk)) call gtk_box_pack_start(hb, junk, TRUE, &
            & TRUE, 0_c_int)
!!$GTK< 3.0!       vb = gtk_vbox_new(FALSE, 0_c_int)
!!$GTK>=3.0!       vb = gtk_box_new(GTK_ORIENTATION_VERTICAL, 0_c_int)
       call gtk_box_pack_start(hb, vb, TRUE, TRUE, 0_c_int)
    else
       vb = content
    end if

    do i = 1, size(message)
       if (i == 1) then
          junk = gtk_label_new(c_null_char)
          call gtk_label_set_markup(junk, '<b><big>'//trim(message(i))// &
               & '</big></b>'//c_null_char)
       else
          junk = gtk_label_new(trim(message(i))//c_null_char)
       end if
       call gtk_box_pack_start(vb, junk, TRUE, TRUE, 0_c_int)
    end do

    select case (button_set)
    case (GTK_BUTTONS_NONE)
    case (GTK_BUTTONS_OK)
       junk = gtk_dialog_add_button(dialog, GTK_STOCK_OK, GTK_RESPONSE_OK)
    case (GTK_BUTTONS_CLOSE)
       junk = gtk_dialog_add_button(dialog, GTK_STOCK_CLOSE, &
            & GTK_RESPONSE_CLOSE)
    case (GTK_BUTTONS_CANCEL)
       junk = gtk_dialog_add_button(dialog, GTK_STOCK_CANCEL, &
            & GTK_RESPONSE_CANCEL)
    case (GTK_BUTTONS_YES_NO)
       junk = gtk_dialog_add_button(dialog, GTK_STOCK_YES, GTK_RESPONSE_YES)
       junk = gtk_dialog_add_button(dialog, GTK_STOCK_NO, GTK_RESPONSE_NO)
    case (GTK_BUTTONS_OK_CANCEL)
       junk = gtk_dialog_add_button(dialog, GTK_STOCK_OK, GTK_RESPONSE_OK)
       junk = gtk_dialog_add_button(dialog, GTK_STOCK_CANCEL, &
            & GTK_RESPONSE_CANCEL)
    case default
       call gtk_widget_destroy(dialog)
       dialog = c_null_ptr

    end select

  end function hl_gtk_message_dialog_new

  !+
  function hl_gtk_message_dialog_show(message, button_set, title, type, &
       & parent) result(resp)

    integer(kind=c_int) :: resp
    character(len=*), dimension(:), intent(in) :: message
    integer(kind=c_int), intent(in) :: button_set
    character(kind=c_char), dimension(*), intent(in), optional :: title
    integer(kind=c_int), intent(in), optional :: type
    type(c_ptr), intent(in), optional :: parent

    ! A DIY version of the message dialogue, needed because both creators
    ! for the built in one are variadic and so not callable from Fortran.
    ! This version runs the dialog as well as creating it.
    !
    ! MESSAGE: string(n): required: The message to display. Since this is
    ! 		a string array, the C_NULL_CHAR terminations are provided
    ! 		internally
    ! BUTTON_SET: integer: required: The set of buttons to display
    ! TITLE: string: optional: Title for the window.
    ! TYPE: c_int: optional: Message type (a GTK_MESSAGE_ value)
    ! PARENT: c_ptr: optional: An optional parent for the dialogue.
    !
    ! This version returns a response code, not a widget pointer.
    !-

    type(c_ptr) :: dialog

    dialog = hl_gtk_message_dialog_new(message, button_set, title, type, &
         & parent)

    if (c_associated(dialog)) then
       call gtk_widget_show_all (dialog)
       resp = gtk_dialog_run(dialog)
       call gtk_widget_destroy(dialog)
    else
       resp = GTK_RESPONSE_NONE
    end if

  end function hl_gtk_message_dialog_show

  !+
  function hl_gtk_about_dialog_new(name, license, license_type, &
       & comments, authors, website, website_label, copyright, version, &
       & documenters, translators, artists, logo, parent) result(about)
    type(c_ptr) :: about
    character(kind=c_char, len=*), intent(in), optional :: name
    character(kind=c_char, len=*), intent(in), optional :: license
    integer(kind=c_int), intent(in), optional :: license_type
    character(kind=c_char, len=*), intent(in), optional :: comments
    character(len=*, kind=c_char), dimension(:), optional, target :: authors, &
         & documenters, artists
    character(kind=c_char, len=*), intent(in), optional :: website, &
         & website_label, translators, copyright, version
    type(c_ptr), intent(in), optional :: logo, parent

    ! A convenience interface for about dialogues.
    !
    ! NAME: string: optional: The name of the program etc.
    ! LICENCE: string: optional: The license for the program.
    ! LICENCE_TYPE: c_int: optional: Specify a license from the
    ! 		GtkLicence enumerator. (Only valid in Gtk+ 3.0 and later)
    ! COMMENTS: string: optional: A description of the program/library...
    ! AUTHORS: string(): optional: A list of the authors.
    ! WEBSITE: string: optional: The website.
    ! WEBSITE_LABEL: string: optional: A label to describe the website.
    ! COPYRIGHT: string: optional: The copyright message.
    ! VERSION: string: optional: The version of the program.
    ! DOCUMENTERS: string(): optional: The documentation authors.
    ! TRANSLATORS: string: optional: The translators (N.B. unlike the
    ! 		other credits, this is a single string).
    ! ARTISTS: string(): optional: The artists involved.
    ! LOGO: c_ptr: optional: A gdk_pixbuf with the project's logo.
    ! PARENT: c_ptr: optional: The parent widget of the window.
    !-

    character(kind=c_char), dimension(:), allocatable :: string
    character(kind=c_char), pointer, dimension(:) :: credit
    type(c_ptr), dimension(:), allocatable :: cptr
    integer :: i

    about = gtk_about_dialog_new()
    if (present(parent)) call gtk_window_set_transient_for(about, parent)

    if (present(name)) then
       call f_c_string(name, string)
       call gtk_about_dialog_set_program_name(about, string)
       deallocate(string)
    end if

    if (present(license)) then
       call f_c_string(license, string)
       call gtk_about_dialog_set_license(about, string)
       deallocate(string)
    else if (present(license_type)) then
!!$GTK>=3.0!       call gtk_about_dialog_set_license_type(about, license_type)
!!$GTK< 3.0!       write(error_unit, "(A)") &
!!$GTK< 3.0!          & "HL_GTK_ABOUT_DIALOG_NEW: LICENCE_TYPE is not available in GTK+ 2.x"
    end if

    if (present(comments)) then
       call f_c_string(comments, string)
       call gtk_about_dialog_set_comments(about, string)
       deallocate(string)
    end if
    if (present(website)) then
       call f_c_string(website, string)
       call gtk_about_dialog_set_website(about, string)
       deallocate(string)
    end if
    if (present(website_label)) then
       call f_c_string(website_label, string)
       call gtk_about_dialog_set_website_label(about, string)
       deallocate(string)
    end if
    if (present(translators)) then
       call f_c_string(translators, string)
       call gtk_about_dialog_set_translator_credits(about, string)
       deallocate(string)
    end if
    if (present(copyright)) then
       call f_c_string(copyright, string)
       call gtk_about_dialog_set_copyright(about, string)
       deallocate(string)
    end if
    if (present(version)) then
       call f_c_string(version, string)
       call gtk_about_dialog_set_version(about, string)
       deallocate(string)
    end if

    if (present(authors)) then
       allocate(cptr(size(authors)+1))
       do i = 1, size(authors)
          call f_c_string(authors(i), string)
          allocate(credit(size(string)))
          credit(:) = string(:)
          cptr(i) = c_loc(credit(1))
          nullify(credit)
       end do
       cptr(size(authors)+1) = c_null_ptr
       call gtk_about_dialog_set_authors(about, cptr)
       deallocate(cptr)
    end if
    if (present(documenters)) then
       allocate(cptr(size(documenters)+1))
       do i = 1, size(documenters)
          call f_c_string(documenters(i), string)
          allocate(credit(size(string)))
          credit(:) = string(:)
          cptr(i) = c_loc(credit(1))
          nullify(credit)
       end do
       cptr(size(authors)+1) = c_null_ptr
       call gtk_about_dialog_set_documenters(about, cptr)
       deallocate(cptr)
    end if
    if (present(artists)) then
       allocate(cptr(size(artists)+1))
       do i = 1, size(artists)
          call f_c_string(artists(i), string)
          allocate(credit(size(string)))
          credit(:) = string(:)
          cptr(i) = c_loc(credit(1))
          nullify(credit)
       end do
       cptr(size(authors)+1) = c_null_ptr
       call gtk_about_dialog_set_artists(about, cptr)
       deallocate(cptr)
    end if

  end function hl_gtk_about_dialog_new

  subroutine hl_gtk_about_dialog_show(name, license, license_type, &
       & comments, authors, website, website_label, copyright, version, &
       & documenters, translators, artists, logo, parent)

    character(kind=c_char, len=*), intent(in), optional :: name
    character(kind=c_char, len=*), intent(in), optional :: license
    integer(kind=c_int), intent(in), optional :: license_type
    character(kind=c_char, len=*), intent(in), optional :: comments
    character(len=*, kind=c_char), dimension(:), optional, target :: authors, &
         & documenters, artists
    character(kind=c_char, len=*), intent(in), optional :: website, &
         & website_label, translators, copyright, version
    type(c_ptr), intent(in), optional :: logo, parent

    ! A convenience interface for about dialogues, displays the dialogue
    ! as well as creating it.
    ! The arguments are identical to hl_gtk_about_dialog_new.
    !-

    type(c_ptr) :: about
    integer(kind=c_int) :: response_id

    about = hl_gtk_about_dialog_new(name, license, license_type, &
         & comments, authors, website, website_label, copyright, version, &
         & documenters, translators, artists, logo, parent)

    response_id =  gtk_dialog_run(about)
    call gtk_widget_destroy(about)
  end subroutine hl_gtk_about_dialog_show

  !+
  subroutine hl_gtk_about_dialog_gtk_fortran(parent)
    type(c_ptr), intent(in), optional :: parent

    ! A standard "About" dialogue for gtk-fortran
    !
    ! PARENT: c_ptr: optional: A parent widget for the dialogue.
    !-

    call hl_gtk_about_dialog_show(name="Gtk-fortran", &
         & authors = [character(len=14) :: "Jerry DeLisle", &
         & "Vincent Magnin", "James Tappin", "Jens Hunger", "Kyle Horne"], &
!!$GTK< 3.0!         & license="GNU GPL 3"//C_NULL_CHAR, &
!!$GTK>=3.0!         & license_type=GTK_LICENSE_GPL_3_0, &
         & comments = &
         &"The gtk-fortran project aims to offer scientists programming "//&
         &"in Fortran a cross-platform library to build Graphical User "//&
         &"Interfaces (GUI)."//c_new_line// & 
         &"Gtk-fortran is a partial GTK / Fortran binding 100% written "//&
         &"in Fortran, thanks to the ISO_C_BINDING module for "//&
         &"interoperability between C and Fortran, which is a part of the "//&
         &"Fortran 2003 standard. Gtk-Fortran also provides a number of "//&
         &"'high-level' interfaces to common widgets."//&
         &c_new_line//c_new_line// & 
         &"GTK is a free software cross-platform graphical library "//&
         &"available for Linux, Unix, Windows and MacOs X."//C_NULL_CHAR, &
         & website="https://github.com/jerryd/gtk-fortran/wiki"//C_NULL_CHAR,&
         & parent=parent)

  end subroutine hl_gtk_about_dialog_gtk_fortran
end module gtk_hl_dialog
