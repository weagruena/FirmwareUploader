; -----------------------------------------------------------------------------
; Excelsior Installation Toolkit (EIT) engine
; -----------------------------------------------------------------------------

!ifndef EIT_INCLUDED
!define EIT_INCLUDED

!define _EITFUNC_UN

; -----------------------------------------------------------------------------
; Include text functions support

!include "TextFunc.nsh"


; -----------------------------------------------------------------------------
!macro MUI_LANGUAGE_EIT LANGUAGE
  
  ;Include a language

  !verbose push
  !verbose ${MUI_VERBOSE}

  !if ${LANGUAGE} == "Brazilian"
    !insertmacro MUI_LANGUAGE PortugueseBR
  !else
  !insertmacro MUI_LANGUAGE ${LANGUAGE}
  !endif
  
  ;Include language file
  !insertmacro LANGFILE_INCLUDE_WITHDEFAULT "${PACKAGENAME}_Lng${LANGUAGE}.nsh" "${PACKAGENAME}_LngEnglish.nsh"

  !verbose pop

!macroend


; -----------------------------------------------------------------------------
!macro EIT_CALL_PREINSTALL INSTALL_CALLBACK_DLL

  InitPluginsDir
  SetOutPath $PLUGINSDIR

  File "/oname=eit_install.dll" "${INSTALL_CALLBACK_DLL}"

  System::Call '$PLUGINSDIR\eit_install.dll::_PreInstall@4(t "$INSTDIR")i  .r0'
  ${if} $0 == "error"
    System::Call '$PLUGINSDIR\eit_install.dll::PreInstall(t "$INSTDIR")i  .r0'
  ${endif}
  ${if} $0 != 0
    Abort "Unexpected error in installation script"
  ${endif}

!macroend


; -----------------------------------------------------------------------------
!macro EIT_CALL_POSTINSTALL

  System::Call '$PLUGINSDIR\eit_install.dll::_PostInstall@4(t "$INSTDIR")i .r0 ? u'
  ${if} $0 == "error"
    System::Call '$PLUGINSDIR\eit_install.dll::PostInstall(t "$INSTDIR")i .r0 ? u'
  ${endif}
  ${if} $0 != 0
    Abort "Unexpected error in installation script"
  ${endif}

!macroend


; -----------------------------------------------------------------------------
!macro EIT_CALL_PREUNINSTALL UNINSTALL_CALLBACK_DLL

  System::Call '$INSTDIR\${UNINSTALL_CALLBACK_DLL}::_PreUninstall@0()i  ().r0 ? u'
  ${if} $0 == "error"
    System::Call '$INSTDIR\${UNINSTALL_CALLBACK_DLL}::PreUninstall()i  ().r0 ? u'
  ${endif}
  ${if} $0 != 0
    Abort "Unexpected error in uninstallation script"
  ${endif}

  Delete "$INSTDIR\${UNINSTALL_CALLBACK_DLL}"

!macroend



;------------------------------------------------------------------------------

!define EIT_LOG_MODE_FILE              "File    "
!define EIT_LOG_MODE_DIRECTORY         "Folder  " ; created folder. remove if empty, else log "can't remove folder" warning
!define EIT_LOG_MODE_DIRECTORY_R       "FolderR " ; recuesive remove this folder
!define EIT_LOG_MODE_REGISTRY          "Registry"
!define EIT_LOG_MODE_REGISTRY_CONTEXT  "InstType"

!define EIT_LENGTH_LOG_MODE    8

; -----------------------------------------------------------------------------
; Declaration of variables

Var eit.InstallLogHandle
Var eit.RegistryContext


;------------------------------------------------------------------------------
!macro EIT_WRITE_LOG_FILE_STR STR

  ${if} "${STR}" != ""
    FileWrite $eit.InstallLogHandle "${STR}$\r$\n"
  ${endif}

!macroend
!define EIT_WriteLogFileStr '!insertmacro EIT_WRITE_LOG_FILE_STR'


;------------------------------------------------------------------------------
!macro EIT_WRITE_LOG_FILE_STR_NO_NEWLINE STR

  ${if} "${STR}" != ""
    FileWrite $eit.InstallLogHandle "${STR}"
  ${endif}

!macroend
!define EIT_WriteLogFileStrNoNewline '!insertmacro EIT_WRITE_LOG_FILE_STR_NO_NEWLINE'

;------------------------------------------------------------------------------
!macro EIT_WRITE_LOG_FILE TYPE VALUE

  FileWrite $eit.InstallLogHandle "${TYPE} ${VALUE}$\r$\n"

!macroend
!define EIT_WriteLogFile '!insertmacro EIT_WRITE_LOG_FILE'


;------------------------------------------------------------------------------
; Adds file(s) to be extracted to the specified output name.
!macro EIT_ADD_FILE DST_FILE SRC_FILE
  StrCpy $0 $KeepOnUninstall

  File "/oname=${DST_FILE}" "${SRC_FILE}"
  ${if} $KeepOnUninstall == 0
    ${EIT_WriteLogFile} "${EIT_LOG_MODE_FILE}" "${DST_FILE}"
  ${endif}

!macroend
!define EIT_AddFile '!insertmacro EIT_ADD_FILE'


;========= isFileExists() =====================================================
; (* ${FileExists} does not understands last slashes in directory name *)
; In  $1 - filename
; Out $1 - 1 or 0
!macro EIT_IS_FILE_EXISTS
    Push $0
    Push $2

    !define ID3445 ${__LINE__}
    StrLen $2 $1                ; $2 := length("c:\a\b\\")
loop_${ID3445}:
    StrCpy $0 $1 "" -1          ; $0 := last '\'
    StrCmp $0 "\" cut_${ID3445} ; if ($0 == "\") goto cut_${ID3445}
    StrCmp $0 "/" cut_${ID3445} ; if ($0== "/") goto cut_${ID3445}
    StrCmp $0 " " cut_${ID3445} ; if ($0 == " ") goto cut_${ID3445}

    ${if} ${FileExists} $1
      StrCpy $1 1
    ${else}
      StrCpy $1 0
    ${endif}

    Pop $2
    Pop $0
    goto return_${ID3445}
cut_${ID3445}:
    StrCpy $1 $1 -1             ; cut last char from $1
    goto loop_${ID3445}
return_${ID3445}:
    !undef ID3445

!macroend
!define EIT_isFileExists '!insertmacro EIT_IS_FILE_EXISTS'


;------------------------------------------------------------------------------
; Postinstall runnable registration (forms function PostinstallRun() and
; registers it as MUI_FINISHPAGE_RUN_FUNCTION
;
!macro EIT_POSTINSTALL_RUN POSTINSTALL_RUN_DIR POSTINSTALL_RUN_EXE POSTINSTALL_RUN_ARG
  !define MUI_FINISHPAGE_RUN
  !define MUI_FINISHPAGE_RUN_FUNCTION PostinstallRun

  Function PostinstallRun
      Push $0
      Push $1
      Push $OUTDIR
      StrCpy $OUTDIR "${POSTINSTALL_RUN_DIR}"
      StrCpy $0      "${POSTINSTALL_RUN_EXE}"
      StrCpy $1      "${POSTINSTALL_RUN_ARG}"
      ExecShell "" "$0" "$1"
      Pop $OUTDIR
      Pop $1
      Pop $0
  FunctionEnd ;  PostinstallRun
!macroend
!define EIT_PostinstallRun '!insertmacro EIT_POSTINSTALL_RUN'



; -----------------------------------------------------------------------------
; Creates a shortcut 'link.lnk' that links to 'target.file', 
; with optional parameters 'parameters'.
!macro EIT_CREATE_SHORTCUT LNK_FILE TARGET_FILE PARAMETERS WORKING_DIR 

  ; $OUTDIR is used for the working directory. You can change 
  ; it by using SetOutPath before creating the Shortcut. 
  Push $OUTDIR
  SetOutPath '${WORKING_DIR}'

  CreateShortCut "${LNK_FILE}" "${TARGET_FILE}" ${PARAMETERS}
  ${EIT_WriteLogFile} "${EIT_LOG_MODE_FILE}" "${LNK_FILE}"

  Pop $0
  SetOutPath $0

!macroend
!define EIT_CreateShortCut '!insertmacro EIT_CREATE_SHORTCUT'


; -----------------------------------------------------------------------------
; Sets the context of $SMPROGRAMS and other shell folders. 
; 0/1 = the 'current user'/'all users' shell folders are used.
!macro EIT_SET_COMMON_INSTALL_TYPE IS_COMMON

  ${if} ${IS_COMMON} != 0
    SetShellVarContext          "all"
    StrCpy $eit.RegistryContext "all"
  ${else}
    SetShellVarContext          "current"
    StrCpy $eit.RegistryContext "current"
  ${endif}

!macroend
!define EIT_SetCommonInstallType '!insertmacro EIT_SET_COMMON_INSTALL_TYPE'

; -----------------------------------------------------------------------------
; Write a dword (32 bit integer) to the registry.
; Only short names of root keys are allowed.
!macro EIT_WRITE_REGISTRY_DWORD  ROOT_KEY SUBKEY KEY_NAME VALUE

  WriteRegDWORD "${ROOT_KEY}" "${SUBKEY}" "${KEY_NAME}" "${VALUE}"
  ${EIT_WriteLogFile} "${EIT_LOG_MODE_REGISTRY}" "${ROOT_KEY} ${SUBKEY}"

!macroend
!define EIT_WriteRegDWORD '!insertmacro EIT_WRITE_REGISTRY_DWORD'


; -----------------------------------------------------------------------------
; Write a string to the registry.
; Only short names of root keys are allowed.
!macro EIT_WRITE_REGISTRY_STR  ROOT_KEY SUBKEY KEY_NAME VALUE

  WriteRegStr "${ROOT_KEY}" "${SUBKEY}" "${KEY_NAME}" "${VALUE}"
  ${EIT_WriteLogFile} "${EIT_LOG_MODE_REGISTRY}" "${ROOT_KEY} ${SUBKEY}"

!macroend
!define EIT_WriteRegStr '!insertmacro EIT_WRITE_REGISTRY_STR'


; -----------------------------------------------------------------------------
!macro EIT_CREATE_FILE_ASSOCIATION FILE_EXT DESCRIPTION COMMAND ARGUMENTS ICON ICONIDX

  ${EIT_WriteRegStr} HKCR "$(^Name).${FILE_EXT}" "" "${DESCRIPTION}"
  ${EIT_WriteRegStr} HKCR "$(^Name).${FILE_EXT}\DefaultIcon" "" "${ICON},${ICONIDX}"
  ${EIT_WriteRegStr} HKCR "$(^Name).${FILE_EXT}\Shell\open\command" "" "$\"${COMMAND}$\" ${ARGUMENTS}"
  ${EIT_WriteRegStr} HKCR "$(^Name).${FILE_EXT}\Shell\open" "FriendlyAppName" "$(^Name)"
  ${EIT_WriteRegStr} HKCR ".${FILE_EXT}" "" "$(^Name).${FILE_EXT}"

!macroend
!define EIT_CreateFileAssociation '!insertmacro EIT_CREATE_FILE_ASSOCIATION'


; -----------------------------------------------------------------------------
!macro EIT_SHOW_FILE_ASSOCIATION_REQUEST FILE_EXT FILE_EXT_APPLICATION DESCRIPTION COMMAND ARGUMENTS
  !define Index "Line${__LINE__}"

  StrCpy $0 "${FILE_EXT}"
  StrCpy $1 "${FILE_EXT_APPLICATION}"
  MessageBox MB_YESNO "$(MSG_FILEEXTS_TEMPLATE)" IDNO "L_${Index}_SkipFileAssociation"

  ${EIT_CreateFileAssociation} "${FILE_EXT}" "${DESCRIPTION}" "${COMMAND}" "${ARGUMENTS}"

"L_${Index}_SkipFileAssociation:"

  !undef Index
!macroend
!define EIT_ShowFileAssociationRequest '!insertmacro EIT_SHOW_FILE_ASSOCIATION_REQUEST'



; -----------------------------------------------------------------------------
!macro EIT_FUNC_DECL_MkCleanupLogString
  
  !ifndef MkCleanupLogString
    !define MkCleanupLogString
    ; -----------------------------------------------------------------------------
    ; In:
    ;     $0 == "a\b" or ""
    ;     $1 == "c:\program files\a\c"
    ; Out:
    ;     $0 == String to write to install.log
    Function MkCleanupLogString
      Push $1
      ${EIT_isFileExists}
      ${if} $1 == 0               ; Allow cleanup if install dir will be created
           Pop $1
    allow:
          StrCpy $0 "${EIT_LOG_MODE_DIRECTORY_R} $1"
          return
      ${endif}
      Pop $1

      ; Install into existent directory - so cleanup is allowed only when $1 ends with $0:

      StrLen $2 $0                ; $2 := length("a\b")
      StrLen $3 $1                ; $3 := length("c:\program files\a\c")
      ${if} $2 > 0
          ${if} $3 > $2
              IntOp $2 0 - $2     ; $2 := -$2
              StrCpy $2 $1 "" $2  ; $2 := "a\c"
              StrCmp $2 $0 allow  ; if ("a\c" == "a\b") goto allow
          ${endif}
      ${endif}

      StrCpy $0 ""
    FunctionEnd ; MkCleanupLogString

  !endif ; MkCleanupLogString

!macroend ; EIT_FUNC_DECL_MkCleanupLogString


;------------------------------------------------------------------------------
; Determine if we'll need remove $INSTDIR recursively after uninstall and
; push string like "FolderR c:\program files\a\b" or push "" if cleanup is not allowed
!macro EIT_MK_CLEANUP_LOG_STRING DEFFOLDER FULLPATH

    Push $0
    Push $1
    Push $2
    Push $3

    StrCpy $1 "${FULLPATH}"
    !ifdef DEFAULT_FOLDER
      StrCpy $0 "${DEFFOLDER}"
    !else
      StrCpy $0 ""
    !endif
    Call MkCleanupLogString

    Pop $3
    Pop $2
    Pop $1
    Exch $0
!macroend
!define EIT_MkCleanupLogStr '!insertmacro EIT_MK_CLEANUP_LOG_STRING'



;------------------------------------------------------------------------------
; If ${EXTRAROOT} folder in not exists then add to $0 string
; like "FolderR c:\program files\a\b"
!macro EIT_ADD_ROOT_CLEANUP_LOG_STRING EXTRAROOT
  Push $1
  StrLen $1 ${EXTRAROOT}   ; $1 := length("c:\program files\a\b")
  ${if} $1 > 3             ; more than "c:\" ({FileExists("c:\") returns FALSE!)
    StrCpy $1 ${EXTRAROOT}
    ${EIT_isFileExists}
    ${if} $1 == 0          ; Allow cleanup if install dir will be created
      StrCpy $0 "$0${EIT_LOG_MODE_DIRECTORY_R} ${EXTRAROOT}$\r$\n"
    ${endif}
  ${endif}
  Pop $1
!macroend
!define EIT_AddRootCleanupLogStr '!insertmacro EIT_ADD_ROOT_CLEANUP_LOG_STRING'


;------------------------------------------------------------------------------
; In:  stack = [delimeter char] [directory] [][]....
; Out: stack = [String to write to install.log] [][]....
Function SliceDir

  Exch $0 ; chop char      ; $0 := '\'
  Exch
  Exch $1 ; input string   ; $1 := "c:\aa\bb.."
  Push $2                  ;
  Push $3                  ;
  Push $4                  ;
  Push $5                  ; .. and old $0..$5 are saved on stack
  
  StrCpy $4 ""             ; $4 := "" - accumulate string for install.log here
  StrCpy $5 ""
  StrCpy $2 2              ; $2 := 2 (to skip "c:\" chars )

  loop:                    ; loop:
    IntOp $2 $2 + 1        ;  ++$2
    StrCpy $3 $1 1 $2      ;  $3 := $1[$2]
    StrCmp $3 $0 nextpart  ;  if ($3 == '\') goto nextpart
    StrCmp $3 "" nextpart0 ;  if ($3 == '')  goto nextpart0
    StrCpy $5 ""           ;
    Goto loop              ; goto loop
  nextpart0:
    StrCmp $5 $0 EOL       ;  To don't process "c:\zz" and "c:\zz\" twice
  nextpart:
    StrCpy $5 $1 $2        ; $5 := "c:\", "c:\aa", "c:\aa\bb" ...
    ${if} $2 > 3           ; ignore "c:\"
      ;-- create $5 and add log for it to $4
      CreateDirectory "$5"
      ${if} $4 != ""
        StrCpy $4 "$4$\r$\n"
      ${endif}
      StrCpy $4 "$4${EIT_LOG_MODE_DIRECTORY} $5"
      ;
    ${endif}
    StrCpy $5 $3           ; "\" or "" used to find possible "...\<EOL>"
    StrCmp $3 $0 loop      ;  if ($3 == '\')  goto loop
  EOL:

    StrCpy $0 $4

    Pop $5
    Pop $4
    Pop $3
    Pop $2
    Pop $1
    Exch $0               ; restore $4..$0 and push log string

FunctionEnd ; SliceDir

;------------------------------------------------------------------------------
; Out: stack = [String to write to install.log] ....
!macro EIT_CREATE_DIR_RECURSIVELY1 DIRECTORY

    Push "${DIRECTORY}"
    Push "\"
    Call SliceDir

!macroend
!define EIT_CreateDirRecursively1 '!insertmacro EIT_CREATE_DIR_RECURSIVELY1'


;------------------------------------------------------------------------------
; Creates recursively specified directory. Used to create project root and
;   shortcut directories
; The error flag is set if the directory couldn't be created.
; You should always specify an absolute path.
!macro EIT_CREATE_DIR_RECURSIVELY DIR_NAME

  Push $0
  ${EIT_CreateDirRecursively1} "${DIR_NAME}"
  Pop $0
  ${if} $KeepOnUninstall == 0
    ${EIT_WriteLogFileStr} "$0"
  ${endif}
  Pop $0

!macroend
!define EIT_CreateDirRecursively '!insertmacro EIT_CREATE_DIR_RECURSIVELY'

;------------------------------------------------------------------------------
; Creates the specified directory. Assumed that parent directory exists
;   at this time
; The error flag is set if the directory couldn't be created.
; You should always specify an absolute path.
!macro EIT_CREATE_DIRECTORY DIR_NAME
  Push $1
  StrCpy $1 "${DIR_NAME}"
  ${EIT_isFileExists}
  ${if} $1 == 0
    CreateDirectory "${DIR_NAME}"
    ${if} $KeepOnUninstall == 0
      StrLen $1 "${DIR_NAME}"   ;
      ${if} $1 > 3              ; more than "c:\"
        ${EIT_WriteLogFileStr} "${EIT_LOG_MODE_DIRECTORY} ${DIR_NAME}"
      ${endif}
    ${endif}
  ${endif}
  Pop $1
!macroend
!define EIT_CreateDirectory '!insertmacro EIT_CREATE_DIRECTORY'


;------------------------------------------------------------------------------
; Open install log and create uninstaller
!macro EIT_START_INSTALLATION UNINSTALLER_PATH UNINSTALLER_FILE CLEANUP_EXTRAROOTS_LOGSTRS

  Push $R0
  Push $R2

  !ifdef CLEANUP_DIR
    ${EIT_MkCleanupLogStr} "${DEFAULT_FOLDER}" "$INSTDIR"
    Pop $R2
  !else
    StrCpy $R2 ""
  !endif

  ${if} '${UNINSTALLER_PATH}' != '$INSTDIR\'
    ${EIT_CreateDirRecursively1} "${UNINSTALLER_PATH}" ; it includes $INSTDIR so both this directories will be created and logged
    Pop $R0
  ${else}
    ${EIT_CreateDirRecursively1} "$INSTDIR"
    Pop $R0
  ${endif}

  SetOutPath "$INSTDIR"

L_OpenInstallLog:
  ClearErrors
  FileOpen $eit.InstallLogHandle "${UNINSTALLER_PATH}${EIT_LOG_FILENAME}" "a"

  ${if} ${Errors}
    StrCpy $0 "${UNINSTALLER_PATH}${EIT_LOG_FILENAME}"
    MessageBox MB_RETRYCANCEL|MB_ICONSTOP "$(^FileError_NoIgnore)" IDRETRY L_OpenInstallLog
    Pop $R2
    Pop $R0
    Abort "$(^CantWrite) ${UNINSTALLER_PATH}${EIT_LOG_FILENAME}"
  ${else}
    FileSeek $eit.InstallLogHandle 0 END
  ${endif}

  ${EIT_WriteLogFileStr}          "$R2"
  ${EIT_WriteLogFileStrNoNewline} "${CLEANUP_EXTRAROOTS_LOGSTRS}"
  ${EIT_WriteLogFileStr}          "$R0"

  ${EIT_WriteLogFile} "${EIT_LOG_MODE_FILE}" "${UNINSTALLER_PATH}${EIT_LOG_FILENAME}"

  WriteUninstaller "${UNINSTALLER_PATH}${UNINSTALLER_FILE}"
  ${EIT_WriteLogFile} "${EIT_LOG_MODE_FILE}" "${UNINSTALLER_PATH}${UNINSTALLER_FILE}"

  Pop $R2
  Pop $R0
!macroend
!define EIT_StartInstallation '!insertmacro EIT_START_INSTALLATION'


;------------------------------------------------------------------------------
!define UNINSTAL_REGISTRY_SUBKEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" 

; Close install log and add uninstall information to Add/Remove Programs
!macro EIT_END_INSTALLATION  COMPANY_NAME UNINSTALLER_PATH UNINSTALLER_FILE

  ; Add uninstall information to Add/Remove Programs
  ${EIT_WriteRegStr}   SHCTX "${UNINSTAL_REGISTRY_SUBKEY}" "DisplayName"     "$(^Name)"
  ${EIT_WriteRegStr}   SHCTX "${UNINSTAL_REGISTRY_SUBKEY}" "UninstallString" "${UNINSTALLER_PATH}${UNINSTALLER_FILE}"
  ${EIT_WriteRegStr}   SHCTX "${UNINSTAL_REGISTRY_SUBKEY}" "Publisher"       "${COMPANY_NAME}"
  ${EIT_WriteRegDWORD} SHCTX "${UNINSTAL_REGISTRY_SUBKEY}" "NoModify"   1
  ${EIT_WriteRegDWORD} SHCTX "${UNINSTAL_REGISTRY_SUBKEY}" "NoRepair"   1


  ${EIT_WriteLogFile} "${EIT_LOG_MODE_REGISTRY_CONTEXT}" "$eit.RegistryContext"

  FileClose $eit.InstallLogHandle
  SetFileAttributes "${UNINSTALLER_PATH}${EIT_LOG_FILENAME}" SYSTEM|HIDDEN

!macroend
!define EIT_EndInstallation '!insertmacro EIT_END_INSTALLATION'


;------------------------------------------------------------------------------
; Close and remove install log
!macro EIT_ABORT_INSTALLATION  UNINSTALLER_PATH UNINSTALLER_FILE

  FileClose $eit.InstallLogHandle

  ClearErrors
  FileOpen $eit.InstallLogHandle "${UNINSTALLER_PATH}${EIT_LOG_FILENAME}" "a"

  ${ifnot} ${Errors}
    FileClose $eit.InstallLogHandle
    ${EIT_ExecuteUninstall} "${UNINSTALLER_PATH}"
  ${endif}

  Delete "${UNINSTALLER_PATH}${EIT_LOG_FILENAME}"
  Delete "${UNINSTALLER_PATH}${UNINSTALLER_FILE}"

!macroend
!define EIT_AbortInstallation '!insertmacro EIT_ABORT_INSTALLATION'


;------------------------------------------------------------------------------
!macro EIT_ExecWait CMD_LINE

  ExecWait '${CMD_LINE}' $0

  ${if} $0 > 0
    Abort 'Failed to execute ${CMD_LINE} (exit code = $0)'
  ${endif}

!macroend
!define EIT_ExecWait '!insertmacro EIT_ExecWait'

;------------------------------------------------------------------------------
!macro EIT_ExecWaitIgnoreErrors CMD_LINE

  ExecWait '${CMD_LINE}' $0

!macroend
!define EIT_ExecWaitIgnoreErrors '!insertmacro EIT_ExecWaitIgnoreErrors'

;------------------------------------------------------------------------------
!macro CASE_DELETE_REGISTRY_KEY ROOT_KEY SUBKEY

  ${case} "${ROOT_KEY}"
      DeleteRegKey "${ROOT_KEY}" "${SUBKEY}"
      ${break}

!macroend
!define case_DeleteRegistryKey '!insertmacro CASE_DELETE_REGISTRY_KEY'


;------------------------------------------------------------------------------
; Function EIT_ExecuteUninstall is called when installtion has failed or 
; the user invoked the uninstallion process.
!macro EIT_ExecuteUninstall
  !ifndef ${_EITFUNC_UN}EIT_ExecuteUninstall
    !define ${_EITFUNC_UN}EIT_ExecuteUninstall '!insertmacro ${_EITFUNC_UN}EIT_ExecuteUninstallCall'
    !insertmacro ${_EITFUNC_UN}TrimNewLines

    Function ${_EITFUNC_UN}EIT_ExecuteUninstall 
      Pop $1 ; install.log file 

      StrCpy $0 0 ; line count


      DetailPrint "$(^Exec) $1"

      ;-------------------------------
      ; reading the install log

      ClearErrors

L_UN_OpenInstallLog:
      SetFileAttributes "$1" NORMAL
      FileOpen $R0 "$1" r

      ${if} ${Errors}
        MessageBox MB_RETRYCANCEL|MB_ICONSTOP "$(MSG_UNABLE_TO_READ_FILE)" IDRETRY L_UN_OpenInstallLog
        Abort "$(MSG_UNABLE_TO_READ_FILE)"
      ${endif}

      loop:
        FileRead $R0 $R1
        ${if} ${Errors}
          goto endloop
        ${endif}
        ${${_EITFUNC_UN}TrimNewLines} "$R1" $R1
        Push $R1
        IntOp $0 $0 + 1 ; line count ++
      goto loop
    endloop:

      FileClose $R0

      ;-------------------------------
      ; executing the install log


      ${while} $0 > 0

        IntOp $0 $0 - 1 ; line count --

        Pop $R0 ; current line
    ;    DetailPrint $R0

        IntOp  $R3 ${EIT_LENGTH_LOG_MODE} + 1
        StrCpy $R1 $R0 ${EIT_LENGTH_LOG_MODE} ; mode
        StrCpy $R2 $R0 "" $R3                 ; operand(s)

        ClearErrors

        ${switch} $R1
        ${case} "${EIT_LOG_MODE_FILE}"
            DetailPrint "$(^Delete): $R2"
            Delete "$R2"
            ${break}

        ${case} "${EIT_LOG_MODE_DIRECTORY}"
            DetailPrint "^RemoveFolder: $R2"
            RMDir "$R2"
            ${break}

        ${case} "${EIT_LOG_MODE_DIRECTORY_R}"
            DetailPrint "^CleanFolder: $R2"
            RMDir /r "$R2"
            ${break}

        ${case} "${EIT_LOG_MODE_REGISTRY}"
            StrCpy $R3 $R2 4     ; root
            StrCpy $R4 $R2 "" 5  ; registry key
            DetailPrint "^Unregistering: $R3 $R4"

            ${switch} $R3
            ${case_DeleteRegistryKey} "HKCR" "$R4"
            ${case_DeleteRegistryKey} "HKLM" "$R4"
            ${case_DeleteRegistryKey} "HKCU" "$R4"
            ${case_DeleteRegistryKey} "HKCC" "$R4"
            ${case_DeleteRegistryKey} "HKDD" "$R4"

            ${case} "HKU "
                StrCpy $R4 $R2 "" 4  ; registry key
                DeleteRegKey HKU "$R4"
                ${break}

            ${case} "SHCT"
                StrCpy $R4 $R2 "" 6  ; registry key
                DeleteRegKey SHCTX "$R4"
                ${break}

            ${endswitch}
            ${break}

        ${case} "${EIT_LOG_MODE_REGISTRY_CONTEXT}"
            ${if} $R2 == "all"
              SetShellVarContext  all
            ${else}
              SetShellVarContext  current
            ${endif}
            ${break}
            
        ${endswitch}

      ${endwhile}

      System::Call 'shell32::SHChangeNotify(i 0x08000000, i 0, i 0, i 0) v'
    FunctionEnd ; un.EIT_ExecuteUninstall
  
  !endif
!macroend ; EIT_ExecuteUninstall


;------------------------------------------------------------------------------
!macro un.EIT_ExecuteUninstall
  !ifndef un.EIT_ExecuteUninstall
     !undef  _EITFUNC_UN
     !define _EITFUNC_UN 'un.'

     !insertmacro EIT_ExecuteUninstall

     !undef  _EITFUNC_UN
     !define _EITFUNC_UN
  !endif
!macroend


;------------------------------------------------------------------------------
!macro EIT_ExecuteUninstallCall UNINSTALLER_PATH

  Push "${UNINSTALLER_PATH}${EIT_LOG_FILENAME}"
  Call EIT_ExecuteUninstall 

!macroend

;------------------------------------------------------------------------------
!macro un.EIT_ExecuteUninstallCall UNINSTALLER_PATH

  Push "${UNINSTALLER_PATH}${EIT_LOG_FILENAME}"
  Call un.EIT_ExecuteUninstall 

!macroend

;------------------------------------------------------------------------------
!insertmacro    EIT_ExecuteUninstall
!insertmacro un.EIT_ExecuteUninstall

!endif ; EIT_INCLUDED
