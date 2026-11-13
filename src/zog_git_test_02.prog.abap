*&---------------------------------------------------------------------*
*& Report ZOG_GIT_TEST_01
*&---------------------------------------------------------------------*
*& abapGit + GitHub bağlantı testi.
*& Kaynak Git'te tutulur, SAP'ye abapGit "Pull" ile gelir.
*&---------------------------------------------------------------------*
REPORT zog_git_test_02.

"test vs code

"ozan test

PARAMETERS p_name TYPE char30 OBLIGATORY.
PARAMETERS p_uname TYPE uname OBLIGATORY DEFAULT 'OG'.

INITIALIZATION.
  p_name = sy-uname.

START-OF-SELECTION.
  WRITE: / TEXT-001, p_name.
  ULINE.
  WRITE: / TEXT-002, sy-sysid, '/', sy-mandt.
  WRITE: / TEXT-003, sy-datum, sy-uzeit.
  WRITE: / TEXT-004, sy-saprl.
