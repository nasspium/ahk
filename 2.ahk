#Include %A_ScriptDir%\Include\Logging.ahk
#Include %A_ScriptDir%\Include\ADB.ahk
#Include %A_ScriptDir%\Include\Gdip_All.ahk
#Include %A_ScriptDir%\Include\Gdip_Imagesearch.ahk

; BallCity - 2025.20.25 - Add OCR library for Username if Inject is on
#Include *i %A_ScriptDir%\Include\OCR.ahk
#Include *i %A_ScriptDir%\Include\Gdip_Extra.ahk

;Need to include string compare for checking ids against keeplist for gamba hits KSBM
#Include *i %A_ScriptDir%\Include\StringCompare.ahk

#SingleInstance on
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetBatchLines, -1
SetTitleMatchMode, 3
CoordMode, Pixel, Screen
#NoEnv

; Allocate and hide the console window to reduce flashing
DllCall("AllocConsole")
WinHide % "ahk_id " DllCall("GetConsoleWindow", "ptr")

;Create folder for gamba keepfriend lists KSBM
NewFolderPath := A_ScriptDir "\GambaLists"
if !FileExist(NewFolderPath)
    FileCreateDir, %NewFolderPath%

global winTitle, changeDate, failSafe, openPack, Delay, failSafeTime, StartSkipTime, Columns, failSafe, scriptName, GPTest, StatusText, defaultLanguage, setSpeed, jsonFileName, pauseToggle, SelectedMonitorIndex, swipeSpeed, godPack, scaleParam, deleteMethod, packs, FriendID, friendIDs, Instances, username, friendCode, stopToggle, friended, runMain, Mains, showStatus, injectMethod, packMethod, loadDir, loadedAccount, nukeAccount, CheckShinyPackOnly, TrainerCheck, FullArtCheck, RainbowCheck, ShinyCheck, dateChange, foundGP, friendsAdded, PseudoGodPack, packArray, CrownCheck, ImmersiveCheck, InvalidCheck, slowMotion, screenShot, accountFile, invalid, starCount, keepAccount
global Mewtwo, Charizard, Pikachu, Mew, Dialga, Palkia, Arceus, Shining, Solgaleo, Lunala, Buzzwole, Eevee, HoOh, Lugia, Springs, Deluxe
global shinyPacks, minStars, minStarsShiny, minStarsA1Mewtwo, minStarsA1Charizard, minStarsA1Pikachu, minStarsA1a, minStarsA2Dialga, minStarsA2Palkia, minStarsA2a, minStarsA2b, minStarsA3Solgaleo, minStarsA3Lunala, minStarsA3a
global DeadCheck
global s4tEnabled, s4tSilent, s4t3Dmnd, s4t4Dmnd, s4t1Star, s4tGholdengo, s4tWP, s4tWPMinCards, s4tDiscordWebhookURL, s4tDiscordUserId, s4tSendAccountXml
global claimDailyMission, wonderpickForEventMissions
global checkWPthanks, wpThanksSavedUsername, wpThanksSavedFriendCode, isCurrentlyDoingWPCheck := false

global avgtotalSeconds
global verboseLogging := false
global showcaseEnabled
global currentPackIs6Card := false
global currentPackIs4Card := false
global injectSortMethod := "ModifiedAsc"
global injectMinPacks := 0
global injectMaxPacks := 39

global waitForEligibleAccounts := 1
global maxWaitHours := 24

;MODIFICACIÓN: Discord User ID para altWebhook
global altDiscordUserId := "452882747237859328"

avgtotalSeconds := 0

global accountOpenPacks, accountFileName, accountFileNameOrig, accountFileNameTmp, accountHasPackInfo, ocrSuccess, packsInPool, packsThisRun, aminutes, aseconds, rerolls, rerollStartTime, maxAccountPackNum, cantOpenMorePacks, rerolls_local, rerollStartTime_local

cantOpenMorePacks := 0
maxAccountPackNum := 9999
aminutes := 0
aseconds := 0

global beginnerMissionsDone, soloBattleMissionDone, intermediateMissionsDone, specialMissionsDone, resetSpecialMissionsDone, accountHasPackInTesting, currentLoadedAccountIndex

beginnerMissionsDone := 0
soloBattleMissionDone := 0
intermediateMissionsDone := 0
specialMissionsDone := 0
resetSpecialMissionsDone := 0
accountHasPackInTesting := 0

global dbg_bbox, dbg_bboxNpause, dbg_bbox_click

dbg_bbox :=0
dbg_bboxNpause :=0
dbg_bbox_click :=0

;Create global variables for if ID matches the keeplist for gamba hits KSBM
global VIP_ID, SUfriendCode, SUfriendName
VIP_ID := 0
SUfriendCode := []
SUfriendName := []

;Create global variables for gamba discord webhook KSBM
global trDiscordWebhookURL
trDiscordWebhookURL := "https://discord.com/api/webhooks/1390290138189529108/gm8zxcsD0fuL7DLqTPJzQ15V5mSgRADBGDm7V0d_-FwE7CX5Ssxn7g_6Hc7OdGm2tlxR"

;Create global variable for google sheets for gamba keepfriends lists, hardcoded for now KSBM
global SheetsID
SheetsID := "1ZQvJ8VOTp1lxAdTwifVH512ZFQTxEfIkoHE-Q2BaG40"

;Read in discord ID and make it a global variable KSBM
global discordUserId
IniRead, discordUserId, %A_ScriptDir%\..\Settings.ini, UserSettings, discordUserId

;OPTIONAL add your alt's friend ID (replace "0" with it) to add them on every pack and gamba KSBM
global altID
altID := 0

;OPTIONAL add and additional webhook (replace "0" with it) to send webhooks messages to both KSBM
global altWebhook
altWebhook := 0

scriptName := StrReplace(A_ScriptName, ".ahk")
winTitle := scriptName
foundGP := false
injectMethod := false
pauseToggle := false
showStatus := true
friended := false
dateChange := false
jsonFileName := A_ScriptDir . "\..\json\Packs.json"

; [... resto del código de inicialización sin cambios hasta la línea ~2400 ...]

; Debido a limitaciones de espacio, continuaré con las funciones modificadas clave:

FoundTradeable(found3Dmnd := 0, found4Dmnd := 0, found1Star := 0, foundGimmighoul := 0) {
    IniWrite, 0, %A_ScriptDir%\%scriptName%.ini, UserSettings, DeadCheck
    keepAccount := true

    foundTradeable := found3Dmnd + found4Dmnd + found1Star + foundGimmighoul

    if (s4tWP && s4tWPMinCards = 2 && foundTradeable < 2) {
        CreateStatusMessage("s4t: insufficient cards (" . foundTradeable . "/2)",,,, false)
        keepAccount := false
        return 
    }

    packDetailsFile := ""
    packDetailsMessage := ""

    if (found3Dmnd > 0) {
        packDetailsFile .= "3DmndX" . found3Dmnd . "_"
        packDetailsMessage .= "Three Diamond (x" . found3Dmnd . "), "
    }
    if (found4Dmnd > 0) {
        packDetailsFile .= "4DmndX" . found4Dmnd . "_"
        packDetailsMessage .= "Four Diamond EX (x" . found4Dmnd . "), "
    }
    if (found1Star > 0) {
        packDetailsFile .= "1StarX" . found1Star . "_"
        packDetailsMessage .= "One Star (x" . found1Star . "), "
    }
    if (foundGimmighoul > 0) {
        packDetailsFile .= "GimmighoulX" . foundGimmighoul . "_"
        packDetailsMessage .= "Gimmighoul (x" . foundGimmighoul . "), "
    }

    packDetailsFile := RTrim(packDetailsFile, "_")
    packDetailsMessage := RTrim(packDetailsMessage, ", ")

    accountFullPath := ""
    accountFile := saveAccount("Tradeable", accountFullPath, packDetailsFile)
    screenShot := Screenshot("Tradeable", "Trades", screenShotFileName)

    statusMessage := "Tradeable cards found"
    if (username)
        statusMessage .= " by " . username
    if (friendCode)
        statusMessage .= " (" . friendCode . ")"

    if (!s4tWP || (s4tWP && foundTradeable < s4tWPMinCards)) {
        CreateStatusMessage("Tradeable cards found! Continuing...",,,, false)

        logMessage := statusMessage . " in instance: " . scriptName . " (" . packsInPool . " packs, " . openPack . ") File name: " . accountFile . " Screenshot file: " . screenShotFileName . " Backing up to the Accounts\\Trades folder and continuing..."
        LogToFile(logMessage, "S4T.txt")

        if (!s4tSilent && s4tDiscordWebhookURL) {
            discordMessage := statusMessage . " in instance: " . scriptName . " (" . packsInPool . " packs, " . openPack . ")\nFound: " . packDetailsMessage . "\nFile name: " . accountFile . "\nBacking up to the Accounts\\Trades folder and continuing..."
            LogToDiscord(discordMessage, screenShot, true, (s4tSendAccountXml ? accountFullPath : ""),, s4tDiscordWebhookURL, s4tDiscordUserId)
        }
        
        ; MODIFICACIÓN: Enviar también a altWebhook con información detallada
        if (altWebhook != 0) {
            altTradeMessage := "**[INSTANCIA " . scriptName . "]** Cartas tradeables encontradas!`n"
            altTradeMessage .= "**Detalles:** " . packDetailsMessage . "`n"
            altTradeMessage .= "**Packs abiertos:** " . packsInPool . "`n"
            altTradeMessage .= "**Pack actual:** " . openPack . "`n"
            altTradeMessage .= "**Usuario:** " . (username ? username : "Unknown") . " (" . (friendCode ? friendCode : "Unknown") . ")`n"
            altTradeMessage .= "**Archivo:** " . accountFile
            
            LogToDiscord(altTradeMessage, screenShot, true, accountFullPath, "", altWebhook, altDiscordUserId)
        }

        return
    }

    friendCode := getFriendCode()

    Sleep, 5000
    fcScreenshot := Screenshot("FRIENDCODE", "Trades")

    tempDir := A_ScriptDir . "\..\Screenshots\temp"
    if !FileExist(tempDir)
        FileCreateDir, %tempDir%

    usernameScreenshotFile := tempDir . "\" . winTitle . "_Username.png"
    adbTakeScreenshot(usernameScreenshotFile)
    Sleep, 100 

    try {
        if (injectMethod && IsFunc("ocr")) {
            playerName := ""
            allowedUsernameChars := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-+"
            usernamePattern := "[\w-]+"

            if(RefinedOCRText(usernameScreenshotFile, 125, 490, 290, 50, allowedUsernameChars, usernamePattern, playerName)) {
            username := playerName
            }
        }
    } catch e {
        LogToFile("Failed to OCR the friend code: " . e.message, "OCR.txt")
    }

    if (FileExist(usernameScreenshotFile)) {
        FileDelete, %usernameScreenshotFile%
    }

    statusMessage := "Tradeable cards found"
    if (username)
        statusMessage .= " by " . username
    if (friendCode)
        statusMessage .= " (" . friendCode . ")"

    logMessage := statusMessage . " in instance: " . scriptName . " (" . packsInPool . " packs, " . openPack . ")\nFile name: " . accountFile . "\nScreenshot file: " . screenShotFileName . "\nBacking up to the Accounts\\Trades folder and continuing..."
    LogToFile(StrReplace(logMessage, "\n", " "), "S4T.txt")

    if (s4tDiscordWebhookURL) {
        discordMessage := statusMessage . " in instance: " . scriptName . " (" . packsInPool . " packs, " . openPack . ")\nFound: " . packDetailsMessage . "\nFile name: " . accountFile . "\nBacking up to the Accounts\\Trades folder and continuing..."
        LogToDiscord(discordMessage, screenShot, true, (s4tSendAccountXml ? accountFullPath : ""), fcScreenshot, s4tDiscordWebhookURL, s4tDiscordUserId)
    }
    
    ; MODIFICACIÓN: Enviar también a altWebhook con información detallada
    if (altWebhook != 0) {
        altTradeMessage := "**[INSTANCIA " . scriptName . "]** Cartas tradeables encontradas!`n"
        altTradeMessage .= "**Detalles:** " . packDetailsMessage . "`n"
        altTradeMessage .= "**Packs abiertos:** " . packsInPool . "`n"
        altTradeMessage .= "**Pack actual:** " . openPack . "`n"
        altTradeMessage .= "**Usuario:** " . (username ? username : "Unknown") . " (" . (friendCode ? friendCode : "Unknown") . ")`n"
        altTradeMessage .= "**Archivo:** " . accountFile
        
        LogToDiscord(altTradeMessage, screenShot, true, accountFullPath, fcScreenshot, altWebhook, altDiscordUserId)
    }

    restartGameInstance("Tradeable cards found. Continuing...", "GodPack")
}

FoundStars(star) {
    global scriptName, DeadCheck, ocrLanguage, injectMethod, openPack, deleteMethod, checkWPthanks
    global wpThanksSavedUsername, wpThanksSavedFriendCode, username, friendCode

    IniWrite, 0, %A_ScriptDir%\%scriptName%.ini, UserSettings, DeadCheck
    keepAccount := true

    screenShot := Screenshot(star)
    accountFullPath := ""
    
    shouldAddWFlag := false
    if (checkWPthanks = 1 && deleteMethod = "Inject Wonderpick 96P+" && injectMethod && loadedAccount) {
        if (star = "Double two star" || star = "Trainer" || star = "Rainbow" || star = "Full Art") {
            shouldAddWFlag := true
        }
    }
    
    accountFile := saveAccount(star, accountFullPath, "", shouldAddWFlag)
    
    if (shouldAddWFlag) {
        AddWFlag()
    }
    
    friendCode := getFriendCode()

    Sleep, 5000
    fcScreenshot := Screenshot("FRIENDCODE")

    tempDir := A_ScriptDir . "\..\Screenshots\temp"
    if !FileExist(tempDir)
        FileCreateDir, %tempDir%

    usernameScreenshotFile := tempDir . "\" . winTitle . "_Username.png"
    adbTakeScreenshot(usernameScreenshotFile)
    Sleep, 100 

    if(star = "Crown" || star = "Immersive" || star = "Shiny")
        RemoveFriends()
    else {
        try {
            if (injectMethod && IsFunc("ocr")) {
                playerName := ""
                allowedUsernameChars := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-+"
                usernamePattern := "[\w-]+"

                if(RefinedOCRText(usernameScreenshotFile, 125, 490, 290, 50, allowedUsernameChars, usernamePattern, playerName)) {
                username := playerName
                }
            }
        } catch e {
            LogToFile("Failed to OCR the friend code: " . e.message, "OCR.txt")
        }
    }

    if (shouldAddWFlag) {
        SaveWPMetadata(accountFileName, username, friendCode)
    }

    if (FileExist(usernameScreenshotFile)) {
        FileDelete, %usernameScreenshotFile%
    }

    CreateStatusMessage(star . " found!",,,, false)

    statusMessage := star . " found"
    if (username)
        statusMessage .= " by " . username
    if (friendCode)
        statusMessage .= " (" . friendCode . ")"

    ; Preparar displayUsername y displayFriendCode para ambos webhooks
    displayUsername := username ? username : "Unknown"
    displayFriendCode := friendCode ? friendCode : "Unknown"

    logMessage := statusMessage . " in instance: " . scriptName . " (" . packsInPool . " packs, " . openPack . ")\nFile name: " . accountFile . "\nBacking up to the Accounts\\SpecificCards folder and continuing..."

    if (star = "Trainer") || (star = "Rainbow") || (star = "Full Art") {
    	friendIDs := ReadFile("ids")
        if(friendIDs) {
            logMessage .= "\nPeople Added:"            
            missingIDs := 0            
            for index, value in friendIDs {
                Loop % SUfriendCode.MaxIndex() {
                    if similarityScore(SUfriendCode[A_Index],value) > 0.9 {
                        if (SUfriendName[A_Index] != "MissingID") {
                            logMessage .= " <@" . SUfriendName[A_Index] . ">"
                        } else {
                            missingIDs += 1    
                        }
                        break
                    }
                }
            }
            if (missingIDs > 0) {
                logMessage .= " " . missingIDs . " unknown user(s) added"
            }
        }
        if (username) && (friendCode)
            logMessage .= "\nManual Add: <" . friendCode . " | " . username . ">"
        LogToDiscord(logMessage, screenShot, false, (sendAccountXml ? accountFullPath : ""), fcScreenshot, trDiscordWebhookURL, discordUserId)
    } else {
        LogToDiscord(logMessage, screenShot, true, (sendAccountXml ? accountFullPath : ""), fcScreenshot)
    }

    ; MODIFICACIÓN: Enviar también a altWebhook con información detallada
    if (altWebhook != 0) {
        altMessage := "**[INSTANCIA " . scriptName . "]** Pack encontrado!`n"
        altMessage .= "**Tipo:** " . star . "`n"
        altMessage .= "**Packs abiertos:** " . packsInPool . "`n"
        altMessage .= "**Pack actual:** " . openPack . "`n"
        altMessage .= "**Usuario:** " . displayUsername . " (" . displayFriendCode . ")`n"
        altMessage .= "**Archivo:** " . accountFileName
        
        LogToDiscord(altMessage, screenShot, true, accountFullPath, fcScreenshot, altWebhook, altDiscordUserId)
    }

    if (star = "Trainer") || (star = "Rainbow") || (star = "Full Art") {
        if (friendIDs)
            GambaRemoveFriends()
    }

    if (star = "Trainer") || (star = "Rainbow") || (star = "Full Art") {
        url := "https://script.google.com/macros/s/AKfycbyPwT22Fof5fX0qJPKtDGKag5RpSRyBKct7-VThLWv5Y_ZyIgSC5m0g38NM5kUXLBk/exec"

        data := ""
        if (friendCode && username) {
            data := "friendCode=" . UriEncode("'" . friendCode . " | " . username)
        } else if (friendCode) {
            data := "friendCode=" . UriEncode("'" . friendCode)
        } else {
            data := "friendCode=" . UriEncode("'Unknown")
        }

        try {
            req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
            req.Open("POST", url, false)
            req.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
            req.Send(data)
            
            if (req.Status = 200) {
                LogToFile("Google Sheets: Successfully sent data - " . data, "GPlog.txt")
            } else {
                LogToFile("Google Sheets Error: " . req.Status . " - " . req.ResponseText, "GPlog.txt")
            }
        } catch e {
            LogToFile("Google Sheets Request Failed: " . e, "GPlog.txt")
        }
    }

    LogToFile(StrReplace(logMessage, "\n", " "), "GPlog.txt")
}

GodPackFound(validity) {
    global scriptName, DeadCheck, ocrLanguage, injectMethod, openPack, deleteMethod, checkWPthanks
    global wpThanksSavedUsername, wpThanksSavedFriendCode, username, friendCode, loadedAccount

    IniWrite, 0, %A_ScriptDir%\%scriptName%.ini, UserSettings, DeadCheck

    if(validity = "Valid") {
        Praise := ["Congrats!", "Congratulations!", "GG!", "Whoa!", "Praise Helix!", "Way to go!", "You did it!", "Awesome!", "Nice!", "Cool!", "You deserve it!", "Keep going!", "This one has to be live!", "No duds, no duds, no duds!", "Fantastic!", "Bravo!", "Excellent work!", "Impressive!", "You're amazing!", "Well done!", "You're crushing it!", "Keep up the great work!", "You're unstoppable!", "Exceptional!", "You nailed it!", "Hats off to you!", "Sweet!", "Kudos!", "Phenomenal!", "Boom! Nailed it!", "Marvelous!", "Outstanding!", "Legendary!", "Youre a rock star!", "Unbelievable!", "Keep shining!", "Way to crush it!", "You're on fire!", "Killing it!", "Top-notch!", "Superb!", "Epic!", "Cheers to you!", "Thats the spirit!", "Magnificent!", "Youre a natural!", "Gold star for you!", "You crushed it!", "Incredible!", "Shazam!", "You're a genius!", "Top-tier effort!", "This is your moment!", "Powerful stuff!", "Wicked awesome!", "Props to you!", "Big win!", "Yesss!", "Champion vibes!", "Spectacular!"]
        invalid := ""
    } else {
        Praise := ["Uh-oh!", "Oops!", "Not quite!", "Better luck next time!", "Yikes!", "That didn't go as planned.", "Try again!", "Almost had it!", "Not your best effort.", "Keep practicing!", "Oh no!", "Close, but no cigar.", "You missed it!", "Needs work!", "Back to the drawing board!", "Whoops!", "That's rough!", "Don't give up!", "Ouch!", "Swing and a miss!", "Room for improvement!", "Could be better.", "Not this time.", "Try harder!", "Missed the mark.", "Keep at it!", "Bummer!", "That's unfortunate.", "So close!", "Gotta do better!"]
        invalid := validity
    }
    Randmax := Praise.Length()
    Random, rand, 1, Randmax
    Interjection := Praise[rand]
    
    starCount := FindBorders("fullart") + FindBorders("rainbow") + FindBorders("trainer")
    
    screenShot := Screenshot(validity)
    accountFullPath := ""
    
    shouldAddWFlag := false
    if (checkWPthanks = 1 && deleteMethod = "Inject Wonderpick 96P+" && validity = "Valid" && injectMethod && loadedAccount) {
        shouldAddWFlag := true
    }
    
    accountFile := saveAccount(validity, accountFullPath, "", shouldAddWFlag)
    
    if (shouldAddWFlag) {
        AddWflag()
    }
    
    friendCode := getFriendCode()

    Sleep, 5000
    fcScreenshot := Screenshot("FRIENDCODE")

    tempDir := A_ScriptDir . "\..\Screenshots\temp"
    if !FileExist(tempDir)
        FileCreateDir, %tempDir%

    usernameScreenshotFile := tempDir . "\" . winTitle . "_Username.png"
    adbTakeScreenshot(usernameScreenshotFile)
    Sleep, 100 

    try {
        if (injectMethod && IsFunc("ocr")) {
            playerName := ""
            allowedUsernameChars := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-+"
            usernamePattern := "[\w-]+"

            if(RefinedOCRText(usernameScreenshotFile, 125, 490, 290, 50, allowedUsernameChars, usernamePattern, playerName)) {
            username := playerName
            }
        }
    } catch e {
        LogToFile("Failed to OCR the friend code: " . e.message, "OCR.txt")
    }

    if (shouldAddWFlag) {
        SaveWPMetadata(accountFileName, username, friendCode)
    }

    if (FileExist(usernameScreenshotFile)) {
        FileDelete, %usernameScreenshotFile%
    }

    CreateStatusMessage(Interjection . (invalid ? " " . invalid : "") . " God Pack found!",,,, false)
    logMessage := Interjection . "\n" . username . " (" . friendCode . ")\n[" . starCount . "/5][" . packsInPool . "P][" . openPack . "] " . invalid . " God Pack found in instance: " . scriptName . "\nFile name: " . accountFile . "\nBacking up to the Accounts\\GodPacks folder and continuing..."
    LogToFile(StrReplace(logMessage, "\n", " "), "GPlog.txt")

    if (validity = "Valid") {
        LogToDiscord(logMessage, screenShot, true, (sendAccountXml ? accountFullPath : ""), fcScreenshot)
    } else if (!InvalidCheck) {
        LogToDiscord(logMessage, screenShot, true, (sendAccountXml ? accountFullPath : ""))
    }
    
    ; MODIFICACIÓN: Enviar también a altWebhook con información detallada
    if (altWebhook != 0) {
        altGPMessage := "**[INSTANCIA " . scriptName . "]** " . Interjection . " God Pack encontrado!`n"
        altGPMessage .= "**Tipo:** " . (invalid ? invalid : "Valid") . "`n"
        altGPMessage .= "**Estrellas:** " . starCount . "/5`n"
        altGPMessage .= "**Packs abiertos:** " . packsInPool . "`n"
        altGPMessage .= "**Pack actual:** " . openPack . "`n"
        altGPMessage .= "**Usuario:** " . (username ? username : "Unknown") . " (" . (friendCode ? friendCode : "Unknown") . ")`n"
        altGPMessage .= "**Archivo:** " . accountFileName
        
        LogToDiscord(altGPMessage, screenShot, true, accountFullPath, fcScreenshot, altWebhook, altDiscordUserId)
    }
}

; [... El resto de las funciones del archivo original permanecen sin cambios ...]
; Por limitaciones de espacio, las demás funciones se mantienen exactamente igual.
; Solo se han modificado: FoundTradeable, FoundStars y GodPackFound

; Las funciones restantes incluyen:
; - CleanupWPMetadata, AddWflag, loadAccount, saveAccount, etc.
; - Todas las funciones de UI y control
; - Funciones de OCR y utilidades
; - El resto del código permanece idéntico al original

CleanupWPMetadata() {
    global winTitle
    
    saveDir := A_ScriptDir "\..\Accounts\Saved\" . winTitle
    metadataFile := saveDir . "\wp_metadata.txt"
    
    if (!FileExist(metadataFile)) {
        return
    }
    
    FileRead, metadataContent, %metadataFile%
    updatedMetadata := ""
    removedCount := 0
    keptCount := 0
    
    Loop, Parse, metadataContent, `n, `r
    {
        if (A_LoopField = "") {
            continue
        }
        
        parts := StrSplit(A_LoopField, "|")
        if (parts.Length() >= 3) {
            accountFileName := parts[1]
            accountFilePath := saveDir . "\" . accountFileName
            
            ; Only keep metadata for accounts that still exist
            if (FileExist(accountFilePath)) {
                updatedMetadata .= A_LoopField . "`n"
                keptCount++
            } else {
                removedCount++
                LogToFile("Removed WP metadata for non-existent account: " . accountFileName)
            }
        }
    }
    
    ; Write cleaned metadata
    FileDelete, %metadataFile%
    if (updatedMetadata != "") {
        FileAppend, %updatedMetadata%, %metadataFile%
    }
    
    LogToFile("WP Metadata cleanup: Kept " . keptCount . " entries, removed " . removedCount . " entries")
}

AddWflag() {
    global accountFileName, winTitle
    
    if (!accountFileName) {
        LogToFile("AddWflag: No accountFileName available")
        return
    }
    
    saveDir := A_ScriptDir "\..\Accounts\Saved\" . winTitle
    oldFilePath := saveDir . "\" . accountFileName
    
    ; Check if file exists
    if (!FileExist(oldFilePath)) {
        LogToFile("AddWflag: File not found: " . oldFilePath)
        return
    }
    
    ; Skip if already has W flag
    if (InStr(accountFileName, "W")) {
        LogToFile("AddWflag: File already has W flag: " . accountFileName)
        return
    }
    
    ; Add W to the metadata
    newFileName := accountFileName
    if (InStr(accountFileName, "(")) {
        ; File has existing metadata - add W to it
        parts1 := StrSplit(accountFileName, "(")
        leftPart := parts1[1]
        
        if (InStr(parts1[2], ")")) {
            parts2 := StrSplit(parts1[2], ")")
            metadata := parts2[1]
            rightPart := parts2[2]
            
            ; Add W to existing metadata
            newMetadata := metadata . "W"
            newFileName := leftPart . "(" . newMetadata . ")" . rightPart
        }
    } else {
        ; File has no metadata - add (W)
        nameAndExtension := StrSplit(accountFileName, ".")
        newFileName := nameAndExtension[1] . "(W).xml"
    }
    
    ; Rename the file
    if (newFileName != accountFileName) {
        newFilePath := saveDir . "\" . newFileName
        FileMove, %oldFilePath%, %newFilePath%
        LogToFile("Added W flag to original account: " . accountFileName . " -> " . newFileName)
        accountFileName := newFileName
    }
}

loadAccount() {

    beginnerMissionsDone := 0
    soloBattleMissionDone := 0
    intermediateMissionsDone := 0
    specialMissionsDone := 0
    accountHasPackInTesting := 0 
    resetSpecialMissionsDone := 0

    if (stopToggle) {
        CreateStatusMessage("Stopping...",,,, false)
        ExitApp
    }

    CreateStatusMessage("Loading account...",,,, false)

    saveDir := A_ScriptDir "\..\Accounts\Saved\" . winTitle
    outputTxt := saveDir . "\list_current.txt"
    
    accountFileName := ""
    accountOpenPacks := 0
    accountFileNameTmp := ""
    accountFileNameOrig := ""
    accountHasPackInfo := 0
    currentLoadedAccountIndex := 0
    
    if FileExist(outputTxt) {
        cycle := 0
        Loop {
            FileRead, fileContent, %outputTxt%
            fileLines := StrSplit(fileContent, "`n", "`r")
                
            if (fileLines.MaxIndex() >= 1) {
                CreateStatusMessage("Loading first available account from list: " . cycle . " attempts")
                loadFile := ""
                foundValidAccount := false
                foundIndex := 0
                
                Loop, % fileLines.MaxIndex() {
                    currentFile := fileLines[A_Index]
                    if (StrLen(currentFile) < 5)
                        continue
                        
                    testFile := saveDir . "\" . currentFile
                    if (!FileExist(testFile))
                        continue
                        
                    if (!InStr(currentFile, "xml"))
                        continue
                    
                    loadFile := testFile
                    accountFileName := currentFile
                    foundValidAccount := true
                    foundIndex := A_Index
                    currentLoadedAccountIndex := A_Index
                    break
                }

				if(InStr(fileLines[1], "T")) {
					; account has a pack under test
					
				}
				if (accountModifiedTimeDiff >= 24){
					if(!InStr(fileLines[1], "T") || accountModifiedTimeDiff >= 5*24) {
						; otherwise account has a pack under test
						accountFileName := fileLines[1]
						break
					}
				}
                
                if (foundValidAccount)
                    break
                    
                cycle++
                
                if (cycle > 5) {  ; Reduced from 10 to 5 for faster failure
                    LogToFile("No valid accounts found in list_current.txt after " . cycle . " attempts")
                    return false
                }
                
                ; Reduced delay between attempts
                Sleep, 500  ; Reduced from Delay(1) which could be 250ms+
            } else {
                LogToFile("list_current.txt is empty or doesn't exist")
                return false
            }
        }
    } else {
        LogToFile("list_current.txt file doesn't exist")
        return false
    }

    adbShell.StdIn.WriteLine("am force-stop jp.pokemon.pokemontcgp")
    waitadb()
    RunWait, % adbPath . " -s 127.0.0.1:" . adbPort . " push " . loadFile . " /sdcard/deviceAccount.xml",, Hide
    waitadb()
    adbShell.StdIn.WriteLine("cp /sdcard/deviceAccount.xml /data/data/jp.pokemon.pokemontcgp/shared_prefs/deviceAccount:.xml")
    waitadb()
    adbShell.StdIn.WriteLine("rm /sdcard/deviceAccount.xml")
    waitadb()
    ; Reliably restart the app: Wait for launch, and start in a clean, new task without animation.
    adbShell.StdIn.WriteLine("am start -W -n jp.pokemon.pokemontcgp/com.unity3d.player.UnityPlayerActivity -f 0x10018000")
    waitadb()
    Sleep, 500   ; Reduced from 1000
    ; Parse account filename for pack info (unchanged)
    if (InStr(accountFileName, "P")) {
        accountFileNameParts := StrSplit(accountFileName, "P")
        accountOpenPacks := accountFileNameParts[1]
        accountFileNameTmp := accountFileNameParts[2]
        accountHasPackInfo := 1
    } else {
        accountFileNameOrig := accountFileName
    }
    
    getMetaData()
    
    return loadFile
}

; NEW function to mark account as successfully used and remove from queue
MarkAccountAsUsed() {
    global currentLoadedAccountIndex, accountFileName, winTitle
    
    if (!currentLoadedAccountIndex || !accountFileName) {
        LogToFile("Warning: MarkAccountAsUsed called but no current account tracked")
        return
    }
    
    saveDir := A_ScriptDir "\..\Accounts\Saved\" . winTitle
    outputTxt := saveDir . "\list_current.txt"
    
    ; Remove the account from list_current.txt
    if FileExist(outputTxt) {
        FileRead, fileContent, %outputTxt%
        fileLines := StrSplit(fileContent, "`n", "`r")
        
        newListContent := ""
        Loop, % fileLines.MaxIndex() {
            if (A_Index != currentLoadedAccountIndex)
                newListContent .= fileLines[A_Index] "`r`n"
        }
        
        FileDelete, %outputTxt%
        FileAppend, %newListContent%, %outputTxt%
    }
    
    ; Track as used with timestamp
    TrackUsedAccount(accountFileName)
    
    ; Reset tracking
    currentLoadedAccountIndex := 0
}

saveAccount(file := "Valid", ByRef filePath := "", packDetails := "", addWFlag := false) {

    filePath := ""

    if (file = "All") {
		metadata := ""
		if(beginnerMissionsDone)
			metadata .= "B"
		if(soloBattleMissionDone)
			metadata .= "S"
		if(intermediateMissionsDone)
			metadata .= "I"
		if(specialMissionsDone)
			metadata .= "X"
        if(accountHasPackInTesting)
            metadata .= "T"
        if(addWFlag)
            metadata .= "W"
			
        saveDir := A_ScriptDir "\..\Accounts\Saved\" . winTitle
        filePath := saveDir . "\" . accountOpenPacks . "P_" . A_Now . "_" . winTitle . "(" . metadata . ").xml"
    } else if (file = "Valid" || file = "Invalid") {
        metadata := ""
        if(addWFlag)
            metadata .= "W"
        
        saveDir := A_ScriptDir "\..\Accounts\GodPacks\"
        xmlFile := A_Now . "_" . winTitle . "_" . file . "_" . packsInPool . "_packs"
        if(metadata != "")
            xmlFile .= "(" . metadata . ")"
        xmlFile .= ".xml"
        filePath := saveDir . xmlFile
    } else if (file = "Tradeable") {
        saveDir := A_ScriptDir "\..\Accounts\Trades\"
		;packsInPool doesn't make sense but nothing does, really.
        xmlFile := A_Now . "_" . winTitle . (packDetails ? "_" . packDetails : "") . "_" . packsInPool . "_packs.xml"
        filePath := saveDir . xmlFile
    } else {
        metadata := ""
        if(addWFlag)
            metadata .= "W"
        
        saveDir := A_ScriptDir "\..\Accounts\SpecificCards\"
        xmlFile := A_Now . "_" . winTitle . "_" . file . "_" . packsInPool . "_packs"
        if(metadata != "")
            xmlFile .= "(" . metadata . ")"
        xmlFile .= ".xml"
        filePath := saveDir . xmlFile
    }

    if !FileExist(saveDir) ; Check if the directory exists
        FileCreateDir, %saveDir% ; Create the directory if it doesn't exist

    count := 0
    Loop {
        if (Debug)
            CreateStatusMessage("Attempting to save account - " . count . "/10")
        else
            CreateStatusMessage("Saving account...",,,, false)

        adbShell.StdIn.WriteLine("cp -f /data/data/jp.pokemon.pokemontcgp/shared_prefs/deviceAccount:.xml /sdcard/deviceAccount.xml")
        waitadb()
        Sleep, 500

        RunWait, % adbPath . " -s 127.0.0.1:" . adbPort . " pull /sdcard/deviceAccount.xml """ . filePath,, Hide

        Sleep, 500

        adbShell.StdIn.WriteLine("rm /sdcard/deviceAccount.xml")

        Sleep, 500

        FileGetSize, OutputVar, %filePath%

        if(OutputVar > 0)
            break

        if(count > 10 && file != "All") {
            CreateStatusMessage("Account not saved. Pausing...",,,, false)
            LogToDiscord("Attempted to save account in " . scriptName . " but was unsuccessful. Pausing. You will need to manually extract.", Screenshot(), true)
            Pause, On
        }
        count++
    }

    ;Add metrics tracking whenever desired card is found
    now := A_NowUTC
    IniWrite, %now%, %A_ScriptDir%\%scriptName%.ini, Metrics, LastEndTimeUTC
    EnvSub, now, 1970, seconds
    IniWrite, %now%, %A_ScriptDir%\%scriptName%.ini, Metrics, LastEndEpoch    

    return xmlFile
}

/* ;Deprecated, use T flag instead
accountFoundGP() {
	saveDir := A_ScriptDir "\..\Accounts\Saved\" . winTitle
	accountFile := saveDir . "\" . accountFileName
	
	FileGetTime, accountFileTime, %accountFile%, M
	accountFileTime += 5, days
	
	FileSetTime, accountFileTime, %accountFile%
}
*/

; MODIFIED TrackUsedAccount function with better timestamp tracking
TrackUsedAccount(fileName) {
    global winTitle
    saveDir := A_ScriptDir "\..\Accounts\Saved\" . winTitle
    usedAccountsLog := saveDir . "\used_accounts.txt"
    
    ; Append with timestamp only (no epoch needed)
    currentTime := A_Now
    FileAppend, % fileName . "|" . currentTime . "`n", %usedAccountsLog%
}

; NEW function to clean up stale used accounts
CleanupUsedAccounts() {
    global winTitle, verboseLogging
    saveDir := A_ScriptDir "\..\Accounts\Saved\" . winTitle
    usedAccountsLog := saveDir . "\used_accounts.txt"
    
    if (!FileExist(usedAccountsLog)) {
        return
    }
    
    ; Read current used accounts
    FileRead, usedAccountsContent, %usedAccountsLog%
    if (!usedAccountsContent) {
        return
    }
    
    ; Calculate current time for comparison (24 hours ago instead of 48)
    cutoffTime := A_Now
    cutoffTime += -24, Hours  ; Reduced from 48 to 24 hours
    
    ; Keep accounts used within last 24 hours
    cleanedContent := ""
    removedCount := 0
    keptCount := 0
    
    ; Also check if the account files still exist
    Loop, Parse, usedAccountsContent, `n, `r
    {
        if (!A_LoopField)
            continue
            
        parts := StrSplit(A_LoopField, "|")
        if (parts.Length() >= 2) {
            fileName := parts[1]
            timestamp := parts[2]
            
            ; Check if account file still exists
            accountFilePath := saveDir . "\" . fileName
            if (!FileExist(accountFilePath)) {
                removedCount++
                if(verboseLogging)
                    LogToFile("Removed used account entry (file no longer exists): " . fileName)
                continue
            }
            
            ; Compare timestamps directly (YYYYMMDDHHMISS format)
            if (timestamp > cutoffTime) {
                ; Account was used within last 24 hours, keep it
                cleanedContent .= A_LoopField . "`n"
                keptCount++
            } else {
                ; Account is older than 24 hours, remove it
                removedCount++
                if(verboseLogging)
                    LogToFile("Removed stale used account: " . fileName . " (used: " . timestamp . ")")
            }
        }
    }
    
    ; Write cleaned content back
    FileDelete, %usedAccountsLog%
    if (cleanedContent) {
        FileAppend, %cleanedContent%, %usedAccountsLog%
    }
    
    if(verboseLogging)
        LogToFile("Cleanup complete: Kept " . keptCount . " recent entries, removed " . removedCount . " stale entries")
}

UpdateAccount() {
    global accountOpenPacks, accountFileName, accountFileNameParts, accountFileNameOrig, ocrSuccess, winTitle
    global aminutes, aseconds, rerolls
    
    accountOpenPacksStr := accountOpenPacks
    if(accountOpenPacks<10)
        accountOpenPacksStr := "0" . accountOpenPacks ; add a trailing 0 for sorting
        
    if(InStr(accountFileName, "P")){
        AccountName := StrSplit(accountFileName , "P")
        accountFileNameParts := StrSplit(accountFileName, "P")  ; Split at P
        AccountNewName := accountOpenPacksStr . "P" . accountFileNameParts[2]
    } else if (ocrSuccess)
        AccountNewName := accountOpenPacksStr . "P_" . accountFileNameOrig
    else
        return ; if OCR is not successful, don't modify account file
    
    if(!InStr(accountFileName, "P") || accountOpenPacks > 0) {          
        saveDir := A_ScriptDir "\..\Accounts\Saved\" . winTitle
        accountFile := saveDir . "\" . accountFileName
        accountNewFile := saveDir . "\" . AccountNewName
        FileMove, %accountFile% , %accountNewFile% ;TODO enable
        FileSetTime,, %accountNewFile%
        accountFileName := AccountNewName
    }
    
    ; Direct display of metrics rather than calling function
    CreateStatusMessage("Avg: " . aminutes . "m " . aseconds . "s | Runs: " . rerolls . " | Account Packs " . accountOpenPacks, "AvgRuns", 0, 605, false, true)
}
ControlClick(X, Y) {
    global winTitle
    ControlClick, x%X% y%Y%, %winTitle%
}

DownloadFile(url, filename) {
    url := url  ; Change to your hosted .txt URL "https://pastebin.com/raw/vYxsiqSs"
    RegRead, proxyEnabled, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings, ProxyEnable
	RegRead, proxyServer, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings, ProxyServer
    localPath = %A_ScriptDir%\..\%filename% ; Change to the folder you want to save the file
    errored := false
    try {
        whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        if (proxyEnabled)
			whr.SetProxy(2, proxyServer)
        whr.Open("GET", url, true)
        whr.Send()
        whr.WaitForResponse()
        ids := whr.ResponseText
    } catch {
        errored := true
    }
    if(!errored) {
        FileDelete, %localPath%
        FileAppend, %ids%, %localPath%
    }
}

ReadFile(filename, numbers := false) {
    FileRead, content, %A_ScriptDir%\..\%filename%.txt

    if (!content)
        return false

    values := []
    for _, val in StrSplit(Trim(content), "`n") {
        cleanVal := RegExReplace(val, "[^a-zA-Z0-9]") ; Remove non-alphanumeric characters
        if (cleanVal != "")
            values.Push(cleanVal)
    }

    return values.MaxIndex() ? values : false
}

Screenshot_dev(fileType := "Dev",subDir := "") {
	global adbShell, scriptName, ocrLanguage, loadDir

	SetWorkingDir %A_ScriptDir%  ; Ensures the working directory is the script's directory

	; Define folder and file paths
	fileDir := A_ScriptDir "\..\Screenshots"
	if !FileExist(fileDir)
		FileCreateDir, %fileDir%
    if (subDir) {
        fileDir .= "\" . subDir
    }
	if !FileExist(fileDir)
		FileCreateDir, %fileDir%
		
	; File path for saving the screenshot locally
    fileName := A_Now . "_" . winTitle . "_" . fileType . ".png"
    filePath := fileDir "\" . fileName

	pBitmapW := from_window(WinExist(winTitle))
	Gdip_SaveBitmapToFile(pBitmapW, filePath) 
	
	sleep 100
	
    try {
        OwnerWND := WinExist(winTitle)
        buttonWidth := 40

        Gui, DevMode_ss%winTitle%:New, +LastFound -DPIScale
		Gui, DevMode_ss%winTitle%:Add, Picture, x0 y0 w275 h534, %filePath%
		Gui, DevMode_ss%winTitle%:Show, w275 h534, Screensho %winTitle%
		
		sleep 100
		msgbox click on top-left corner and bottom-right corners
		
		KeyWait, LButton, D
		MouseGetPos , X1, Y1, OutputVarWin, OutputVarControl
		KeyWait, LButton, U
		Y1 -= 31
		;MsgBox, The cursor is at X%X1% Y%Y1%.
		
		KeyWait, LButton, D
		MouseGetPos , X2, Y2, OutputVarWin, OutputVarControl
		KeyWait, LButton, U
		Y2 -= 31
		;MsgBox, The cursor is at X%X2% Y%Y2%.
		
		W:=X2-X1
		H:=Y2-Y1
		
		pBitmap := Gdip_CloneBitmapArea(pBitmapW, X1, Y1, W, H)
		
		InputBox, fileName, ,"Enter the name of the needle to save"
		
		fileDir := A_ScriptDir . "\Scale125"
		filePath := fileDir "\" . fileName . ".png"
		Gdip_SaveBitmapToFile(pBitmap, filePath) 
		
		msgbox click on coordinate for adbClick
		
		KeyWait, LButton, D
		MouseGetPos , X3, Y3, OutputVarWin, OutputVarControl
		KeyWait, LButton, U
		Y3 -= 31
		
		MsgBox, 	
		(LTrim
			ctrl+C to copy: 
			FindOrLoseImage(%X1%, %Y1%, %X2%, %Y2%, , "%fileName%", 0, failSafeTime)
            FindImageAndClick(%X1%, %Y1%, %X2%, %Y2%, , "%fileName%", %X3%, %Y3%, sleepTime)
			adbClick_wbb(%X3%, %Y3%)
		)
    }
    catch {
            msgbox Failed to create screenshot GUI
    }	
	return filePath
}

Screenshot(fileType := "Valid", subDir := "", ByRef fileName := "") {
    global adbShell, adbPath, packs
    SetWorkingDir %A_ScriptDir%  ; Ensures the working directory is the script's directory
		
    ; Define folder and file paths
    fileDir := A_ScriptDir "\..\Screenshots"
    if !FileExist(fileDir)
        FileCreateDir, fileDir
    if (subDir) {
        fileDir .= "\" . subDir
		if !FileExist(fileDir)
			FileCreateDir, fileDir
    }
	if (filename = "PACKSTATS") {
        fileDir .= "\temp"
		if !FileExist(fileDir)
			FileCreateDir, fileDir
	}

    ; File path for saving the screenshot locally
    fileName := A_Now . "_" . winTitle . "_" . fileType . "_" . packsInPool . "_packs.png"
    if (filename = "PACKSTATS") 
        fileName := "packstats_temp.png"
    filePath := fileDir "\" . fileName

    pBitmapW := from_window(WinExist(winTitle))
    pBitmap := Gdip_CloneBitmapArea(pBitmapW, 18, 175, 240, 227)
    ;scale 100%
    if (scaleParam = 287) {
        pBitmap := Gdip_CloneBitmapArea(pBitmapW, 17, 168, 245, 230)
    }
    Gdip_DisposeImage(pBitmapW)
    Gdip_SaveBitmapToFile(pBitmap, filePath)

    ; Don't dispose pBitmap if it's a PACKSTATS screenshot
    if (filename != "PACKSTATS") {
        Gdip_DisposeImage(pBitmap)
		return filePath
    }
    
    ; For PACKSTATS, return both values and delete temp file after OCR is done
    return {filepath: filePath, bitmap: pBitmap, deleteAfterUse: true}
}


; Pause Script
PauseScript:
    CreateStatusMessage("Pausing...",,,, false)
    Pause, On
return

; Resume Script
ResumeScript:
    CreateStatusMessage("Resuming...",,,, false)
    StartSkipTime := A_TickCount ;reset stuck timers
    failSafe := A_TickCount
    Pause, Off
return

; Stop Script
StopScript:
    ToggleStop()
return

DevMode:
	ToggleDevMode()
return

ShowStatusMessages:
    ToggleStatusMessages()
return

ReloadScript:
    Reload
return

TestScript:
    ToggleTestScript()
return

ToggleStop() {
    global stopToggle, friended
    stopToggle := true
    if (!friended)
        ExitApp
    else
        CreateStatusMessage("Stopping script at the end of the run...",,,, false)
}

ToggleTestScript() {
    global GPTest
    if(!GPTest) {
        CreateStatusMessage("In GP Test Mode",,,, false)
        GPTest := true
    }
    else {
        CreateStatusMessage("Exiting GP Test Mode",,,, false)
        ;Winset, Alwaysontop, On, %winTitle%
        GPTest := false
    }
}

; Function to append a time and variable pair to the JSON file
AppendToJsonFile(variableValue) {
    global jsonFileName
    if (!jsonFileName || !variableValue) {
        return
    }

    ; Read the current content of the JSON file
    FileRead, jsonContent, %jsonFileName%
    if (jsonContent = "") {
        jsonContent := "[]"
    }

    ; Parse and modify the JSON content
    jsonContent := SubStr(jsonContent, 1, StrLen(jsonContent) - 1) ; Remove trailing bracket
    if (jsonContent != "[")
        jsonContent .= ","
    jsonContent .= "{""time"": """ A_Now """, ""variable"": " variableValue "}]"

    ; Write the updated JSON back to the file
    FileDelete, %jsonFileName%
    FileAppend, %jsonContent%, %jsonFileName%
}

from_window(ByRef image) {
    ; Thanks tic - https://www.autohotkey.com/boards/viewtopic.php?t=6517

    ; Get the handle to the window.
    image := (hwnd := WinExist(image)) ? hwnd : image

    ; Restore the window if minimized! Must be visible for capture.
    if DllCall("IsIconic", "ptr", image)
        DllCall("ShowWindow", "ptr", image, "int", 4)

    ; Get the width and height of the client window.
    VarSetCapacity(Rect, 16) ; sizeof(RECT) = 16
    DllCall("GetClientRect", "ptr", image, "ptr", &Rect)
        , width  := NumGet(Rect, 8, "int")
        , height := NumGet(Rect, 12, "int")

    ; struct BITMAPINFOHEADER - https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfoheader
    hdc := DllCall("CreateCompatibleDC", "ptr", 0, "ptr")
    VarSetCapacity(bi, 40, 0)                ; sizeof(bi) = 40
        , NumPut(       40, bi,  0,   "uint") ; Size
        , NumPut(    width, bi,  4,   "uint") ; Width
        , NumPut(  -height, bi,  8,    "int") ; Height - Negative so (0, 0) is top-left.
        , NumPut(        1, bi, 12, "ushort") ; Planes
        , NumPut(       32, bi, 14, "ushort") ; BitCount / BitsPerPixel
        , NumPut(        0, bi, 16,   "uint") ; Compression = BI_RGB
        , NumPut(        3, bi, 20,   "uint") ; Quality setting (3 = low quality, no anti-aliasing)
    hbm := DllCall("CreateDIBSection", "ptr", hdc, "ptr", &bi, "uint", 0, "ptr*", pBits:=0, "ptr", 0, "uint", 0, "ptr")
    obm := DllCall("SelectObject", "ptr", hdc, "ptr", hbm, "ptr")

    ; Print the window onto the hBitmap using an undocumented flag. https://stackoverflow.com/a/40042587
    DllCall("PrintWindow", "ptr", image, "ptr", hdc, "uint", 0x3) ; PW_CLIENTONLY | PW_RENDERFULLCONTENT
    ; Additional info on how this is implemented: https://www.reddit.com/r/windows/comments/8ffr56/altprintscreen/

    ; Convert the hBitmap to a Bitmap using a built in function as there is no transparency.
    DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "ptr", hbm, "ptr", 0, "ptr*", pBitmap:=0)

    ; Cleanup the hBitmap and device contexts.
    DllCall("SelectObject", "ptr", hdc, "ptr", obm)
    DllCall("DeleteObject", "ptr", hbm)
    DllCall("DeleteDC",     "ptr", hdc)

    return pBitmap
}

; ===== TIMER FUNCTIONS =====
RefreshAccountLists:
    createAccountList(scriptName)
    Return

CleanupUsedAccountsTimer:
    CleanupUsedAccounts()
    Return

; ===== HOTKEYS =====
~+F5::Reload
~+F6::Pause
~+F7::ToggleStop()
~+F8::ToggleDevMode()
;~+F8::ToggleStatusMessages()
;~F9::restartGameInstance("F9")

ToggleDevMode() {
	
    try {
        OwnerWND := WinExist(winTitle)
        x4 := x + 5
        y4 := y + 44
        buttonWidth := 40

        Gui, DevMode%winTitle%:New, +LastFound
        Gui, DevMode%winTitle%:Font, s5 cGray Norm Bold, Segoe UI  ; Normal font for input labels
        Gui, DevMode%winTitle%:Add, Button, % "x" . (buttonWidth * 0) . " y0 w" . buttonWidth . " h25 gbboxScript", bound box
		
		Gui, DevMode%winTitle%:Add, Button, % "x" . (buttonWidth * 1) . " y0 w" . buttonWidth . " h25 gbboxNpauseScript", bbox pause
		
		Gui, DevMode%winTitle%:Add, Button, % "x" . (buttonWidth * 2) . " y0 w" . buttonWidth . " h25 gscreenshotscript", screen grab
		
		Gui, DevMode%winTitle%:Show, w250 h100, Dev Mode %winTitle%
		
    }
    catch {
            CreateStatusMessage("Failed to create button GUI.",,,, false)
    }	
}

screenshotscript:
	Screenshot_dev()
return

bboxScript:
    ToggleBBox()
return

ToggleBBox() {
	dbg_bbox := !dbg_bbox
}

bboxNpauseScript:
    TogglebboxNpause()
return

TogglebboxNpause() {
	dbg_bboxNpause := !dbg_bboxNpause
}

dbg_bbox :=0
dbg_bboxNpause :=0
dbg_bbox_click :=0

ToggleStatusMessages() {
    if(showStatus) {
        showStatus := False
    }
    else
        showStatus := True
}

bboxDraw(X1, Y1, X2, Y2, color) {
	WinGetPos, xwin, ywin, Width, Height, %winTitle%
    BoxWidth := X2-X1
    BoxHeight := Y2-Y1
    ; Create a GUI
    Gui, BoundingBox%winTitle%:+AlwaysOnTop +ToolWindow -Caption +E0x20
    Gui, BoundingBox%winTitle%:Color, 123456
    Gui, BoundingBox%winTitle%:+LastFound  ; Make the GUI window the last found window for use by the line below. (straght from documentation)
    WinSet, TransColor, 123456 ; Makes that specific color transparent in the gui

    ; Create the borders and show
	Gui, BoundingBox%winTitle%:Add, Progress, x0 y0 w%BoxWidth% h2 %color%
	Gui, BoundingBox%winTitle%:Add, Progress, x0 y0 w2 h%BoxHeight% %color%
	Gui, BoundingBox%winTitle%:Add, Progress, x%BoxWidth% y0 w2 h%BoxHeight% %color%
	Gui, BoundingBox%winTitle%:Add, Progress, x0 y%BoxHeight% w%BoxWidth% h2 %color%
	
	xshow := X1+xwin
	yshow := Y1+ywin
	Gui, BoundingBox%winTitle%:Show, x%xshow% y%yshow% NoActivate
    Sleep, 100

}

bboxDraw2(X1, Y1, X2, Y2, color) {
	WinGetPos, xwin, ywin, Width, Height, %winTitle%
    BoxWidth := 10
    BoxHeight := 10
	Xm1:=X1-(BoxWidth/2)
	Xm2:=X2-(BoxWidth/2)
	Ym1:=Y1-(BoxWidth/2)
	Ym2:=Y2-(BoxWidth/2)
	Xh1:=Xm1+BoxWidth
	Xh2:=Xm2+BoxWidth
	Yh1:=Ym1+BoxHeight
	Yh2:=Ym2+BoxHeight
	
    ; Create a GUI
    Gui, BoundingBox%winTitle%:+AlwaysOnTop +ToolWindow -Caption +E0x20
    Gui, BoundingBox%winTitle%:Color, 123456
    Gui, BoundingBox%winTitle%:+LastFound  ; Make the GUI window the last found window for use by the line below. (straght from documentation)
    WinSet, TransColor, 123456 ; Makes that specific color transparent in the gui

    ; Create the borders and show
	Gui, BoundingBox%winTitle%:Add, Progress, x%Xm1% y%Ym1% w%BoxWidth% h2 %color%
	Gui, BoundingBox%winTitle%:Add, Progress, x%Xm1% y%Ym1% w2 h%BoxHeight% %color%
	Gui, BoundingBox%winTitle%:Add, Progress, x%Xh1% y%Ym1% w2 h%BoxHeight% %color%
	Gui, BoundingBox%winTitle%:Add, Progress, x%Xm1% y%Yh1% w%BoxWidth% h2 %color%
	
    ; Create the borders and show
	Gui, BoundingBox%winTitle%:Add, Progress, x%Xm2% y%Ym2% w%BoxWidth% h2 %color%
	Gui, BoundingBox%winTitle%:Add, Progress, x%Xm2% y%Ym2% w2 h%BoxHeight% %color%
	Gui, BoundingBox%winTitle%:Add, Progress, x%Xh2% y%Ym2% w2 h%BoxHeight% %color%
	Gui, BoundingBox%winTitle%:Add, Progress, x%Xm2% y%Yh2% w%BoxWidth% h2 %color%
	
	xshow := xwin
	yshow := ywin
	Gui, BoundingBox%winTitle%:Show, x%xshow% y%yshow% NoActivate
    Sleep, 100

}

adbSwipe_wbb(params) {
	if(dbg_bbox)
		bboxAndPause_swipe(params, dbg_bboxNpause)
    adbSwipe(params)
}

bboxAndPause_swipe(params, doPause := False) {
	paramsplit := StrSplit(params , " ")
	X1:=round(paramsplit[1] / 535 * 277)
	Y1:=round((paramsplit[2] / 960 * 489) + 44)
	X2:=round(paramsplit[3] / 535 * 277)
	Y2:=round((paramsplit[4] / 960 * 489) + 44)
	speed:=paramsplit[5]
	CreateStatusMessage("Swiping (" . X1 . "," . Y1 . ") to (" . X2 . "," . Y2 . ") speed " . speed,,,, false)
	
	color := "BackgroundYellow"
	
	;bboxDraw2(X1, Y1, X2, Y2, color)
	
	bboxDraw(X1-5, Y1-5, X1+5, Y1+5, color)
    if (doPause) {
        Pause
    }
    Gui, BoundingBox%winTitle%:Destroy
	
	bboxDraw(X2-5, Y2-5, X2+5, Y2+5, color)
    if (doPause) {
        Pause
    }
	Gui, BoundingBox%winTitle%:Destroy
}

adbClick_wbb(X,Y)  {
	if(dbg_bbox)
		bboxAndPause_click(X, Y, dbg_bboxNpause)
	adbClick(X,Y)
}

bboxAndPause_click(X, Y, doPause := False) {
	CreateStatusMessage("Clicking X " . X . " Y " . Y,,,, false)
	
	color := "BackgroundBlue"
	
	bboxDraw(X-5, Y-5, X+5, Y+5, color)
	
    if (doPause) {
        Pause
    }

    if GetKeyState("F4", "P") {
        Pause
    }
    Gui, BoundingBox%winTitle%:Destroy
}

bboxAndPause_immage(X1, Y1, X2, Y2, pNeedleObj, vret := False, doPause := False) {
	CreateStatusMessage("Searching " . pNeedleObj.Name . " returns " . vret,,,, false)
	
	if(vret>0) {
		color := "BackgroundGreen"
	} else {
		color := "BackgroundRed"
	}
	
	bboxDraw(X1, Y1, X2, Y2, color)
	
    if (doPause && vret) {
        Pause
    }

    if GetKeyState("F4", "P") {
        Pause
    }
    Gui, BoundingBox%winTitle%:Destroy
}

Gdip_ImageSearch_wbb(pBitmapHaystack,pNeedle,ByRef OutputList=""
,OuterX1=0,OuterY1=0,OuterX2=0,OuterY2=0,Variation=0,Trans=""
,SearchDirection=1,Instances=1,LineDelim="`n",CoordDelim=",") {

	vret := Gdip_ImageSearch(pBitmapHaystack,pNeedle.needle,OutputList,OuterX1,OuterY1,OuterX2,OuterY2,Variation,Trans,SearchDirection,Instances,LineDelim,CoordDelim)
	if(dbg_bbox)
		bboxAndPause_immage(OuterX1, OuterY1, OuterX2, OuterY2, pNeedle, vret, dbg_bboxNpause)
	return vret
}

GetNeedle(Path) {
    static NeedleBitmaps := Object()
	
    if (NeedleBitmaps.HasKey(Path)) {
        return NeedleBitmaps[Path]
    } else {
        pNeedle := Gdip_CreateBitmapFromFile(Path)
		needleObj := Object()
		needleObj.Path := Path
		pathsplit := StrSplit(Path , "\")
		needleObj.Name := pathsplit[pathsplit.MaxIndex()]
		needleObj.needle := pNeedle
        NeedleBitmaps[Path] := needleObj
        return needleObj
    }
		
    if (NeedleBitmaps.HasKey(Path)) {
        return NeedleBitmaps[Path]
    } else {
        pNeedle := Gdip_CreateBitmapFromFile(Path)
        NeedleBitmaps[Path] := pNeedle
        return pNeedle
    }
}

MonthToDays(year, month) {
    static DaysInMonths := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    days := 0
    Loop, % month - 1 {
        days += DaysInMonths[A_Index]
    }
    if (month > 2 && IsLeapYear(year))
        days += 1
    return days
}

IsLeapYear(year) {
    return (Mod(year, 4) = 0 && Mod(year, 100) != 0) || Mod(year, 400) = 0
}

Delay(n) {
    global Delay
    msTime := Delay * n
    Sleep, msTime
}

DoTutorial() {
    FindImageAndClick(105, 396, 121, 406, , "Country", 143, 370) ;select month and year and click

    Delay(1)
    adbClick_wbb(80, 400)
    Delay(1)
    adbClick_wbb(80, 375)
    Delay(1)
    failSafe := A_TickCount
    failSafeTime := 0

    Loop {
        Delay(1)
        if(FindImageAndClick(100, 386, 138, 416, , "Month", , , , 1, failSafeTime))
            break
        Delay(1)
        adbClick_wbb(142, 159)
        Delay(1)
        adbClick_wbb(80, 400)
        Delay(1)
        adbClick_wbb(80, 375)
        Delay(1)
        adbClick_wbb(82, 422)
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Month`n(" . failSafeTime . "/45 seconds)")
    } ;select month and year and click

    adbClick_wbb(200, 400)
    Delay(1)
    adbClick_wbb(200, 375)
    Delay(1)
    failSafe := A_TickCount
    failSafeTime := 0
    Loop { ;select month and year and click
        Delay(1)
        if(FindImageAndClick(148, 384, 256, 419, , "Year", , , , 1, failSafeTime))
            break
        Delay(1)
        adbClick_wbb(142, 159)
        Delay(1)
        adbClick_wbb(142, 159)
        Delay(1)
        adbClick_wbb(200, 400)
        Delay(1)
        adbClick_wbb(200, 375)
        Delay(1)
        adbClick_wbb(142, 159)
        Delay(1)
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Year`n(" . failSafeTime . "/45 seconds)")
    } ;select month and year and click

    Delay(1)
    if(FindOrLoseImage(93, 471, 122, 485, , "CountrySelect", 0)) {
        FindImageAndClick(110, 134, 164, 160, , "CountrySelect2", 141, 237, 500)
        failSafe := A_TickCount
        failSafeTime := 0
        Loop {
            countryOK := FindOrLoseImage(93, 450, 122, 470, , "CountrySelect", 0, failSafeTime)
            birthFound := FindOrLoseImage(116, 352, 138, 389, , "Birth", 0, failSafeTime)
            if(countryOK)
                adbClick_wbb(124, 250)
            else if(!birthFound)
                adbClick_wbb(140, 474)
            else if(birthFound)
                break
            Delay(2)
            failSafeTime := (A_TickCount - failSafe) // 1000
            CreateStatusMessage("Waiting for country select for " . failSafeTime . "/45 seconds")
        }
    } else {
        FindImageAndClick(116, 352, 138, 389, , "Birth", 140, 474, 1000)
    }

    ;wait date confirmation screen while clicking ok

    FindImageAndClick(210, 285, 250, 315, , "TosScreen", 203, 371, 1000) ;wait to be at the tos screen while confirming birth

    FindImageAndClick(129, 477, 156, 494, , "Tos", 139, 299, 1000) ;wait for tos while clicking it

    FindImageAndClick(210, 285, 250, 315, , "TosScreen", 142, 486, 1000) ;wait to be at the tos screen and click x

    FindImageAndClick(129, 477, 156, 494, , "Privacy", 142, 339, 1000) ;wait to be at the tos screen

    FindImageAndClick(210, 285, 250, 315, , "TosScreen", 142, 486, 1000) ;wait to be at the tos screen, click X

    Delay(1)
    adbClick_wbb(261, 374)

    Delay(1)
    adbClick_wbb(261, 406)

    Delay(1)
    adbClick_wbb(145, 484)

    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        if(FindImageAndClick(30, 336, 53, 370, , "Save", 145, 484, , 2, failSafeTime)) ;wait to be at create save data screen while clicking
            break
        Delay(1)
        adbClick_wbb(261, 406)
        if(FindImageAndClick(30, 336, 53, 370, , "Save", 145, 484, , 2, failSafeTime)) ;wait to be at create save data screen while clicking
            break
        Delay(1)
        adbClick_wbb(261, 374)
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Save`n(" . failSafeTime . "/45 seconds)")
    }

    Delay(1)

    adbClick_wbb(143, 348)

    Delay(1)

    FindImageAndClick(51, 335, 107, 359, , "Link") ;wait for link account screen%
    Delay(1)
    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        if(FindOrLoseImage(51, 335, 107, 359, , "Link", 0, failSafeTime)){
            adbClick_wbb(140, 460)
            Loop {
                Delay(1)
                if(FindOrLoseImage(51, 335, 107, 359, , "Link", 1, failSafeTime)){
                    adbClick_wbb(140, 380) ; click ok on the interrupted while opening pack prompt
                    break
                }
                failSafeTime := (A_TickCount - failSafe) // 1000
            }
        } else if(FindOrLoseImage(110, 350, 150, 404, , "Confirm", 0, failSafeTime)){
            adbClick_wbb(203, 364)
        } else if(FindOrLoseImage(215, 371, 264, 418, , "Complete", 0, failSafeTime)){
            adbClick_wbb(140, 370)
        } else if(FindOrLoseImage(0, 46, 20, 70, , "Cinematic", 0, failSafeTime)){
            break
        }
        Delay(1)
        failSafeTime := (A_TickCount - failSafe) // 1000
    }

    if(setSpeed = 3){
        FindImageAndClick(25, 145, 70, 170, , "Platin", 18, 109, 2000) ; click mod settings
        FindImageAndClick(9, 170, 25, 190, , "One", 26, 180) ; click mod settings
        Delay(1)
        adbClick_wbb(41, 296)
        Delay(1)
    }

    FindImageAndClick(110, 230, 182, 257, , "Welcome", 253, 506, 110) ;click through cutscene until welcome page

    if(setSpeed = 3){
        FindImageAndClick(25, 145, 70, 170, , "Platin", 18, 109, 2000) ; click mod settings
        FindImageAndClick(182, 170, 194, 190, , "Three", 187, 180) ; click mod settings
        Delay(1)
        adbClick_wbb(41, 296)
    }
    FindImageAndClick(190, 241, 225, 270, , "Name", 189, 438) ;wait for name input screen
    /* ; Picks Erika at creation - disabled
    Delay(1)
    if(FindOrLoseImage(147, 160, 157, 169, , "Erika", 1)) {
        adbClick_wbb(143, 207)
        Delay(1)
        adbClick_wbb(143, 207)
        FindImageAndClick(165, 294, 173, 301, , "ChooseErika", 143, 306)
        FindImageAndClick(190, 241, 225, 270, , "Name", 143, 462) ;wait for name input screen
    }
    */
    FindImageAndClick(0, 476, 40, 502, , "OK", 139, 257) ;wait for name input screen

    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        ; Check for AccountName in Settings.ini
        IniRead, accountNameValue, %A_ScriptDir%\..\Settings.ini, UserSettings, AccountName, ERROR

        ; Use AccountName if it exists and isn't empty
        if (accountNameValue != "ERROR" && accountNameValue != "") {
            Random, randomNum, 1, 500 ; Generate random number from 1 to 500
            username := accountNameValue . "-" . randomNum
            username := SubStr(username, 1, 14)  ; max character limit
            if(verboseLogging)
                LogToFile("Using AccountName: " . username)
        } else {
            fileName := A_ScriptDir . "\..\usernames.txt"
            if(FileExist(fileName))
                name := ReadFile("usernames")
            else
                name := ReadFile("usernames_default")

            Random, randomIndex, 1, name.MaxIndex()
            username := name[randomIndex]
            username := SubStr(username, 1, 14)  ; max character limit
            if(verboseLogging)
                LogToFile("Using random username: " . username)
        }

        adbInput(username)
        Delay(1)
        if(FindImageAndClick(121, 490, 161, 520, , "Return", 185, 372, , 10))
            break
        adbClick_wbb(90, 370)
        Delay(1)
        adbClick_wbb(139, 254) ; 139 254 194 372
        Delay(1)
        adbClick_wbb(139, 254)
        Delay(1)
        EraseInput() ; incase the random pokemon is not accepted
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("In failsafe for Trace. " . failSafeTime . "/45 seconds")
        if(failSafeTime > 45)
            restartGameInstance("Stuck at name")
    }

    Delay(1)

    adbClick_wbb(140, 424)

    FindImageAndClick(225, 273, 235, 290, , "Pack", 140, 424) ;wait for pack to be ready  to trace
    if(setSpeed > 1) {
        FindImageAndClick(25, 145, 70, 170, , "Platin", 18, 109, 2000) ; click mod settings
        FindImageAndClick(9, 170, 25, 190, , "One", 26, 180) ; click mod settings
        Delay(1)
    }
    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        adbSwipe_wbb(adbSwipeParams)
        Sleep, 10
        if(FindOrLoseImage(225, 273, 235, 290, , "Pack", 1, failSafeTime)){
            if(setSpeed > 1) {
                if(setSpeed = 3)
                    FindImageAndClick(182, 170, 194, 190, , "Three", 187, 180) ; click 3x
                else
                    FindImageAndClick(100, 170, 113, 190, , "Two", 107, 180) ; click 2x
            }
            adbClick_wbb(41, 296)
            break
        }
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Pack`n(" . failSafeTime . "/45 seconds)")
    }

    FindImageAndClick(34, 99, 74, 131, , "Swipe", 140, 375) ;click through cards until needing to swipe up
    if(setSpeed > 1) {
        FindImageAndClick(25, 145, 70, 170, , "Platin", 18, 109, 2000) ; click mod settings
        FindImageAndClick(9, 170, 25, 190, , "One", 26, 180) ; click mod settings
        Delay(1)
    }
    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        adbSwipe_wbb("266 770 266 355 60")
        Sleep, 10
        if(FindOrLoseImage(120, 70, 150, 95, , "SwipeUp", 0, failSafeTime)){
            if(setSpeed > 1) {
                if(setSpeed = 3)
                    FindImageAndClick(182, 170, 194, 190, , "Three", 187, 180) ; click mod settings
                else
                    FindImageAndClick(100, 170, 113, 190, , "Two", 107, 180) ; click mod settings
            }
            adbClick_wbb(41, 296)
            break
        }
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for swipe up for " . failSafeTime . "/45 seconds")
        Delay(1)
    }

    Delay(1)
    if(setSpeed > 2) {
        FindImageAndClick(136, 420, 151, 436, , "Move", 134, 375, 500) ; click through until move
        FindImageAndClick(50, 394, 86, 412, , "Proceed", 141, 483, 750) ;wait for menu to proceed then click ok. increased delay in between clicks to fix freezing on 3x speed
    } else {
        FindImageAndClick(136, 420, 151, 436, , "Move", 134, 375) ; click through until move
        FindImageAndClick(50, 394, 86, 412, , "Proceed", 141, 483) ;wait for menu to proceed then click ok
    }

    Delay(1)
    adbClick_wbb(204, 371)

    FindImageAndClick(46, 368, 103, 411, , "Gray") ;wait for for missions to be clickable

    Delay(1)
    adbClick_wbb(247, 472)

    FindImageAndClick(115, 97, 174, 150, , "Pokeball", 247, 472, 5000) ; click through missions until missions is open

    Delay(1)
    adbClick_wbb(141, 294)
    Delay(1)
    adbClick_wbb(141, 294)
    Delay(1)
    FindImageAndClick(124, 168, 162, 207, , "Register", 141, 294, 1000) ; wait for register screen
    Delay(6)
    adbClick_wbb(140, 500)

    FindImageAndClick(115, 255, 176, 308, , "Mission") ; wait for mission complete screen

    FindImageAndClick(46, 368, 103, 411, , "Gray", 143, 360) ;wait for for missions to be clickable

    FindImageAndClick(170, 160, 220, 200, , "Notifications", 145, 194) ;click on packs. stop at booster pack tutorial

    Delay(3)
    adbClick_wbb(142, 436)
    Delay(3)
    adbClick_wbb(142, 436)
    Delay(3)
    adbClick_wbb(142, 436)
    Delay(3)
    adbClick_wbb(142, 436)

    FindImageAndClick(225, 273, 235, 290, , "Pack", 239, 497) ;wait for pack to be ready  to Trace
    if(setSpeed > 1) {
        FindImageAndClick(25, 145, 70, 170, , "Platin", 18, 109, 2000) ; click mod settings
        FindImageAndClick(9, 170, 25, 190, , "One", 26, 180) ; click mod settings
        Delay(1)
    }
    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        adbSwipe_wbb(adbSwipeParams)
        Sleep, 10
        if(FindOrLoseImage(225, 273, 235, 290, , "Pack", 1, failSafeTime)){
            if(setSpeed > 1) {
                if(setSpeed = 3)
                    FindImageAndClick(182, 170, 194, 190, , "Three", 187, 180) ; click mod settings
                else
                    FindImageAndClick(100, 170, 113, 190, , "Two", 107, 180) ; click mod settings
            }
            adbClick_wbb(41, 296)
            break
        }
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Pack`n(" . failSafeTime . "/45 seconds)")
        Delay(1)
    }

    FindImageAndClick(170, 98, 270, 125, 5, "Opening", 239, 497, 50) ;skip through cards until results opening screen

    FindImageAndClick(233, 486, 272, 519, , "Skip", 146, 496) ;click on next until skip button appears

    FindImageAndClick(120, 70, 150, 100, , "Next", 239, 497, , 2)

    FindImageAndClick(53, 281, 86, 310, , "Wonder", 146, 494) ;click on next until skip button appearsstop at hourglasses tutorial

    Delay(3)

    adbClick_wbb(140, 358)

    FindImageAndClick(191, 393, 211, 411, , "Shop", 146, 444) ;click until at main menu

    FindImageAndClick(87, 232, 131, 266, , "Wonder2", 79, 411) ; click until wonder pick tutorial screen

    FindImageAndClick(114, 430, 155, 441, , "Wonder3", 190, 437) ; click through tutorial

    Delay(2)

    FindImageAndClick(155, 281, 192, 315, , "Wonder4", 202, 347, 500) ; confirm wonder pick selection

    Delay(2)

    adbClick_wbb(208, 461)

    if(setSpeed = 3) ;time the animation
        Sleep, 1500
    else
        Sleep, 2500

    FindImageAndClick(60, 130, 202, 142, 10, "Pick", 208, 461, 350) ;stop at pick a card

    Delay(1)

    adbClick_wbb(187, 345)

    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        if(setSpeed = 3)
            continueTime := 1
        else
            continueTime := 3

        if(FindOrLoseImage(233, 486, 272, 519, , "Skip", 0, failSafeTime)) {
            adbClick_wbb(239, 497)
        } else if(FindOrLoseImage(110, 230, 182, 257, , "Welcome", 0, failSafeTime)) { ;click through to end of tut screen
            break
        } else if(FindOrLoseImage(120, 70, 150, 100, , "Next", 0, failSafeTime)) {
            adbClick_wbb(146, 494) ;146, 494
        } else if(FindOrLoseImage(120, 70, 150, 100, , "Next2", 0, failSafeTime)) {
            adbClick_wbb(146, 494) ;146, 494
        } else {
            adbClick_wbb(187, 345)
            Delay(1)
            adbClick_wbb(143, 492)
            Delay(1)
            adbClick_wbb(143, 492)
            Delay(1)
        }
        Delay(1)

        ; adbClick_wbb(66, 446)
        ; Delay(1)
        ; adbClick_wbb(66, 446)
        ; Delay(1)
        ; adbClick_wbb(66, 446)
        ; Delay(1)
        ; adbClick_wbb(187, 345)
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for End`n(" . failSafeTime . "/45 seconds)")
    }

    FindImageAndClick(120, 316, 143, 335, , "Main", 192, 449) ;click until at main menu

    return true
}

SelectPack(HG := false) {
    global openPack, packArray
	
	; define constants
	MiddlePackX := 140
	RightPackX := 215
	LeftPackX := 60
	HomeScreenAllPackY := 203
	
	PackScreenAllPackY := 320
	
	SelectExpansionFirstRowY := 275
	SelectExpansionSecondRowY := 390
	
	SelectExpansionRightCollumnMiddleX := 203
	SelectExpansionLeftCollumnMiddleX := 73
	3PackExpansionLeft := -40
	3PackExpansionRight := 40
	2PackExpansionLeft := -20
	2PackExpansionRight := 15 ; avoiding clicking UI elements behind
	
	inselectexpansionscreen := 0
	
    packy := HomeScreenAllPackY
    if (openPack == "Springs") {
        packx := RightPackX
    } else if (openPack == "Deluxe") {
            packx := MiddlePackX
    } else {
            packx := LeftPackX
    }
	
	if(openPack == "Deluxe" || openPack == "HoOh" || openPack == "Springs") {
		PackIsInHomeScreen := 1
    } else {
        PackIsInHomeScreen := 0
	}
	
	if(openPack == "Deluxe") {
		PackIsLatest := 1
	} else {
		PackIsLatest := 0
	}
		
	if (openPack == "Springs" || openPack == "Deluxe") {
		packInTopRowsOfSelectExpansion := 1
	} else {
		packInTopRowsOfSelectExpansion := 0
	}

	if(HG = "First" && injectMethod && loadedAccount ){
		; when First and injection, if there are free packs, we don't land/start in home screen, 
		; and we have also to search for closed during pack, hourglass, etc.
		
		failSafe := A_TickCount
		failSafeTime := 0
		Loop {
			adbClick_wbb(packx, HomeScreenAllPackY) ; click until points appear (if free packs, will land in pack scree, if no free packs, this will select the middle pack and go to same screen as if there were free packs)
			Delay(1)
			if(FindOrLoseImage(233, 400, 264, 428, , "Points", 0, failSafeTime)) {
				break
			}
			else if(!renew && !getFC) {
				if(FindOrLoseImage(241, 377, 269, 407, , "closeduringpack", 0)) {
					adbClick_wbb(139, 371)
				}
            }
			else if(FindOrLoseImage(175, 165, 255, 235, , "Hourglass3", 0)) {
				;TODO hourglass tutorial still broken after injection
				Delay(3)
				adbClick_wbb(146, 441)
				Delay(3)
				adbClick_wbb(146, 441)
				Delay(3)
				adbClick_wbb(146, 441)
				Delay(3)

				FindImageAndClick(98, 184, 151, 224, , "Hourglass1", 168, 438, 500, 5) ;stop at hourglasses tutorial 2
				Delay(1)

				adbClick_wbb(203, 436)
				FindImageAndClick(236, 198, 266, 226, , "Hourglass2", 180, 436, 500) ;stop at hourglasses tutorial 2 180 to 203?
			}

			failSafeTime := (A_TickCount - failSafe) // 1000
			CreateStatusMessage("Waiting for Points`n(" . failSafeTime . "/90 seconds)")
		}
		
		if(!friendIDs && friendID = "") {
			; if we don't need to add any friends we can select directly the latest packs, or go directly to select other booster screen, 
				
			if(PackIsLatest) {   ; if selected pack is the latest pack select directly from the pack select screen
				packy := PackScreenAllPackY ; Y coordinate is lower when in pack select screen then in home screen
				
				if(packx != MiddlePackX) { ; if it is already the middle Pack, no need to click again
					Delay(5) ; lowered from 10 to 5 to speed up inject users
					adbClick_wbb(packx, packy) 
					Delay(5) ; lowered from 10 to 5 to speed up inject users
				}
			} else {
				FindImageAndClick(115, 140, 160, 155, , "SelectExpansion", 248, 459, 1000) ; if selected pack is not the latest pack click directly select other boosters
				
				if(PackIsInHomeScreen) {
					; the only one that is not handled below because should show in home page
					inselectexpansionscreen := 1
				}
			} 
		}
	} else {
		; if not first or not injected, or friends were added, always start from home page
		FindImageAndClick(233, 400, 264, 428, , "Points", packx, packy, 1000)  ; open selected pack from home page
	}

	; if not the ones showing in home screen, click select other booster packs
    if (!PackIsInHomeScreen && !inselectexpansionscreen) {
        FindImageAndClick(115, 140, 160, 155, , "SelectExpansion", 248, 459, 1000)
		inselectexpansionscreen := 1
	}
	
	if(inselectexpansionscreen) {
        ; packs that can be opened after 1 swipe down
        if (openPack = "Buzzwole" || openPack = "Solgaleo" || openPack = "Lunala") {
            X := 266
            Y1 := 430
            Y2 := 50

            Loop, 1 {
                adbSwipe(X . " " . Y1 . " " . X . " " . Y2 . " " . 250)
                Sleep, 300 ;
            }

            if (openPack == "Buzzwole") {
                packx := SelectExpansionLeftCollumnMiddleX
                packy := 438
            } else if (openPack = "Solgaleo") {
                packx := SelectExpansionRightCollumnMiddleX + 2PackExpansionLeft
                packy := 438
            } else if (openPack = "Lunala") {
                packx := 209 ;custom click to avoid accidentally clicking Points UI after
                ; packx := SelectExpansionRightCollumnMiddleX + 2PackExpansionRight
                packy := 438
            }
        }

        ; packs that can be opened after fully swiping down
        if (openPack = "Shining" || openPack = "Arceus" || openPack = "Dialga" || openPack = "Palkia" || openPack = "Mew" || openPack = "Charizard" || openPack = "Mewtwo" || openPack = "Pikachu") {
            
            X := 266
            Y1 := 430
            Y2 := 50
    
            Loop, 5 {
                adbSwipe(X . " " . Y1 . " " . X . " " . Y2 . " " . 250)
                Sleep, 300 ;
            }
            if (openPack = "Shining") {
                packx := SelectExpansionLeftCollumnMiddleX
                packy := 130
			} else if (openPack = "Arceus") {
                packx := SelectExpansionRightCollumnMiddleX
                packy := 130
            } else if (openPack = "Dialga") {
                packx := SelectExpansionLeftCollumnMiddleX + 2PackExpansionLeft
                packy := 275
            } else if (openPack = "Palkia") {
                packx := SelectExpansionLeftCollumnMiddleX + 2PackExpansionRight
                packy := 275
            } else if (openPack = "Mew") {
                packx := SelectExpansionRightCollumnMiddleX
                packy := 275
            } else if (openPack = "Charizard") {
                packx := SelectExpansionLeftCollumnMiddleX + 3PackExpansionLeft
                packy := 400
            } else if (openPack = "Mewtwo") {
                packx := SelectExpansionLeftCollumnMiddleX
                packy := 400
            } else if (openPack = "Pikachu") {
                packx := SelectExpansionLeftCollumnMiddleX + 3PackExpansionRight
                packy := 400
            }
        } else { ; No swipe, inital screen
            if (openPack == "Deluxe") {
				packy := SelectExpansionFirstRowY
                packx := SelectExpansionLeftCollumnMiddleX                
            } else if (openPack == "Springs") {
				packy := SelectExpansionFirstRowY
                packx := SelectExpansionRightCollumnMiddleX
            } else if (openPack == "HoOh") {
				packy := SelectExpansionSecondRowY
                packx := SelectExpansionLeftCollumnMiddleX + 2PackExpansionLeft
            } else if (openPack == "Lugia") {
				packy := SelectExpansionSecondRowY
                packx := SelectExpansionLeftCollumnMiddleX + 2PackExpansionRight
            } else if (openPack == "Eevee") {
				packy := SelectExpansionSecondRowY
                packx := SelectExpansionRightCollumnMiddleX
            }
        }
        FindImageAndClick(233, 400, 264, 428, , "Points", packx, packy)
    }
	
	if(HG = "First" && injectMethod && loadedAccount && !accountHasPackInfo) {
		FindPackStats()
	}
	
    if(HG = "Tutorial") {
        FindImageAndClick(236, 198, 266, 226, , "Hourglass2", 180, 436, 500) ;stop at hourglasses tutorial 2 180 to 203?
    }
    else if(HG = "HGPack") {
        failSafe := A_TickCount
        failSafeTime := 0
        Loop {
            if(FindOrLoseImage(60, 440, 90, 480, , "HourglassPack", 0, failSafeTime)) {
                break
            }else if(FindOrLoseImage(49, 449, 70, 474, , "HourGlassAndPokeGoldPack", 0, failSafeTime)) {
                break
            }else if(FindOrLoseImage(60, 440, 90, 480, , "PokeGoldPack", 0, failSafeTime)) {
                break
            }else if(FindOrLoseImage(92, 299, 115, 317, , "notenoughitems", 0)) {
                cantOpenMorePacks := 1
            }
			if(cantOpenMorePacks)
				return
            adbClick_wbb(161, 423)
            Delay(1)
            failSafeTime := (A_TickCount - failSafe) // 1000
            CreateStatusMessage("Waiting for HourglassPack3`n(" . failSafeTime . "/45 seconds)")
        }
        failSafe := A_TickCount
        failSafeTime := 0
        Loop {
            if(FindOrLoseImage(60, 440, 90, 480, , "HourglassPack", 1, failSafeTime)) {
                break
            }
            adbClick_wbb(205, 458)
            Delay(1)
            failSafeTime := (A_TickCount - failSafe) // 1000
            CreateStatusMessage("Waiting for HourglassPack4`n(" . failSafeTime . "/45 seconds)")
        }
    }
    else { 
        failSafe := A_TickCount
        failSafeTime := 0
        Loop {
            adbClick_wbb(151, 420)  ; open button
            
            if(FindOrLoseImage(233, 486, 272, 519, , "Skip2", 0)) {
                break
            } else if(FindOrLoseImage(92, 299, 115, 317, , "notenoughitems", 0)) {
                cantOpenMorePacks := 1
            } else if(FindOrLoseImage(60, 440, 90, 480, , "HourglassPack", 0, 1) || FindOrLoseImage(49, 449, 70, 474, , "HourGlassAndPokeGoldPack", 0, 1)) {
                adbClick_wbb(205, 458)  ; Handle unexpected HG pack confirmation
            } else {
                adbClick_wbb(200, 451)  ; Additional fallback click
            }
        
            if(cantOpenMorePacks)
                return
                
            Delay(1)
            failSafeTime := (A_TickCount - failSafe) // 1000
            CreateStatusMessage("Waiting for Skip2`n(" . failSafeTime . "/45 seconds)")
        }
    }
}

PackOpening() {
    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        adbClick_wbb(146, 439)
        Delay(1)
        if(FindOrLoseImage(225, 273, 235, 290, , "Pack", 0, failSafeTime)) {
            break ;wait for pack to be ready to Trace and click skip
        } else if(FindOrLoseImage(92, 299, 115, 317, , "notenoughitems", 0)) {
            cantOpenMorePacks := 1
        } else if(FindOrLoseImage(60, 440, 90, 480, , "HourglassPack", 0, 1) || FindOrLoseImage(49, 449, 70, 474, , "HourGlassAndPokeGoldPack", 0, 1)) {
            adbClick_wbb(205, 458) ; handle unexpected no packs available
        } else {
            adbClick_wbb(239, 497)
        }
		
		if(cantOpenMorePacks)
			return
		
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Pack`n(" . failSafeTime . "/45 seconds)")
        if(failSafeTime > 45){
			RemoveFriends()
            IniWrite, 1, %A_ScriptDir%\%scriptName%.ini, UserSettings, DeadCheck
            restartGameInstance("Stuck at Pack")
		}
    }

    if(setSpeed > 1) {
    FindImageAndClick(25, 145, 70, 170, , "Platin", 18, 109, 2000) ; click mod settings
    FindImageAndClick(9, 170, 25, 190, , "One", 26, 180) ; click mod settings
        Delay(1)
    }
    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        adbSwipe_wbb(adbSwipeParams)
        Sleep, 10
        if (FindOrLoseImage(225, 273, 235, 290, , "Pack", 1, failSafeTime)){
        if(setSpeed > 1) {
            if(setSpeed = 3)
                    FindImageAndClick(182, 170, 194, 190, , "Three", 187, 180) ; click mod settings
            else
                    FindImageAndClick(100, 170, 113, 190, , "Two", 107, 180) ; click mod settings
        }
            adbClick_wbb(41, 296)
            break
        }
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Trace`n(" . failSafeTime . "/45 seconds)")
        Delay(1)
    }

    FindImageAndClick(170, 98, 270, 125, 5, "Opening", 239, 497, 50) ;skip through cards until results opening screen

    CheckPack()
    
	if(!friendIDs && friendID = "" && accountOpenPacks >= maxAccountPackNum) 
		return

    ;FindImageAndClick(233, 486, 272, 519, , "Skip", 146, 494) ;click on next until skip button appears

    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        Delay(1)
        if(FindOrLoseImage(233, 486, 272, 519, , "Skip", 0, failSafeTime)) {
            adbClick_wbb(239, 497)
        } else if(FindOrLoseImage(120, 70, 150, 100, , "Next", 0, failSafeTime)) {
            adbClick_wbb(146, 494) ;146, 494
        } else if(FindOrLoseImage(120, 70, 150, 100, , "Next2", 0, failSafeTime)) {
            adbClick_wbb(146, 494) ;146, 494
        } else if(FindOrLoseImage(121, 465, 140, 485, , "ConfirmPack", 0, failSafeTime)) {
            break
        } else if(FindOrLoseImage(178, 193, 251, 282, , "Hourglass", 0, failSafeTime)) {
            break
		} else {
			adbClick_wbb(146, 494) ;146, 494
		} 
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Home`n(" . failSafeTime . "/45 seconds)")
        if(failSafeTime > 45)
            restartGameInstance("Stuck at Home")
    }
}

HourglassOpening(HG := false, NEIRestart := true) {
    if(!HG) {
        Delay(3)
        adbClick_wbb(146, 441) ; 146 440
        Delay(3)
        adbClick_wbb(146, 441)
        Delay(3)
        adbClick_wbb(146, 441)
        Delay(3)

        FindImageAndClick(98, 184, 151, 224, , "Hourglass1", 168, 438, 500, 5) ;stop at hourglasses tutorial 2
        Delay(1)

        adbClick_wbb(203, 436) ; 203 436

        if(packMethod) {
            AddFriends(true)
            SelectPack("Tutorial")
        }
        else {
            FindImageAndClick(236, 198, 266, 226, , "Hourglass2", 180, 436, 500) ;stop at hourglasses tutorial 2 180 to 203?
			
			if(cantOpenMorePacks)
				return
        }
    }
    if(!packMethod) {
        failSafe := A_TickCount
        failSafeTime := 0
        Loop {
            if(FindOrLoseImage(60, 440, 90, 480, , "HourglassPack", 0, failSafeTime)) {
                break
            }else if(FindOrLoseImage(40, 440, 70, 474, , "HourGlassAndPokeGoldPack", 0, failSafeTime)) {
                break
            }else if(FindOrLoseImage(60, 440, 90, 480, , "PokeGoldPack", 0, failSafeTime)) {
                break
            }else if(FindOrLoseImage(92, 299, 115, 317, , "notenoughitems", 0)) {
                cantOpenMorePacks := 1
            }
			if(cantOpenMorePacks)
				return
            if(failSafeTime >= 45) {
                restartGameInstance("Stuck waiting for HourglassPack")
                return
            }
            adbClick_wbb(146, 439)
            Delay(1)
            CreateStatusMessage("Waiting for HourglassPack`n(" . failSafeTime . "/45 seconds)")
        }
        failSafe := A_TickCount
        failSafeTime := 0
        Loop {
            if(FindOrLoseImage(60, 440, 90, 480, , "HourglassPack", 1, failSafeTime)) {
                break
            }
            adbClick_wbb(205, 458)
            Delay(1)
            failSafeTime := (A_TickCount - failSafe) // 1000
            CreateStatusMessage("Waiting for HourglassPack2`n(" . failSafeTime . "/45 seconds)")
        }
    }
    Loop {
        adbClick_wbb(146, 439)
        Delay(1)
        if(FindOrLoseImage(225, 273, 235, 290, , "Pack", 0, failSafeTime))
            break ;wait for pack to be ready to Trace and click skip
        else
            adbClick_wbb(239, 497)
			
		if(cantOpenMorePacks)
			return

        if(FindOrLoseImage(191, 393, 211, 411, , "Shop", 0, failSafeTime)){
            SelectPack("HGPack")
        }
		
        clickButton := FindOrLoseImage(145, 440, 258, 480, 80, "Button", 0, failSafeTime)
        if(clickButton) {
            StringSplit, pos, clickButton, `,  ; Split at ", "
            if (scaleParam = 287) {
                pos2 += 5
            }
            adbClick_wbb(pos1, pos2)
        }
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Pack`n(" . failSafeTime . "/45 seconds)")
        if(failSafeTime > 45) {
            if(injectMethod && loadedAccount && friended) {
                IniWrite, 1, %A_ScriptDir%\%scriptName%.ini, UserSettings, DeadCheck
            }
            restartGameInstance("Stuck at Pack")
        }
    }

    if(setSpeed > 1) {
    FindImageAndClick(25, 145, 70, 170, , "Platin", 18, 109, 2000) ; click mod settings
    FindImageAndClick(9, 170, 25, 190, , "One", 26, 180) ; click mod settings
        Delay(1)
    }
    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        adbSwipe_wbb(adbSwipeParams)
        Sleep, 10
        if (FindOrLoseImage(225, 273, 235, 290, , "Pack", 1, failSafeTime)){
        if(setSpeed > 1) {
            if(setSpeed = 3)
                    FindImageAndClick(182, 170, 194, 190, , "Three", 187, 180) ; click mod settings
            else
                    FindImageAndClick(100, 170, 113, 190, , "Two", 107, 180) ; click mod settings
        }
            adbClick_wbb(41, 296)
            break
        }
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Trace`n(" . failSafeTime . "/45 seconds)")
        Delay(1)
    }

    FindImageAndClick(170, 98, 270, 125, 5, "Opening", 239, 497, 50) ;skip through cards until results opening screen

    CheckPack()
	
	if(!friendIDs && friendID = "" && accountOpenPacks >= maxAccountPackNum) 
		return

    ;FindImageAndClick(233, 486, 272, 519, , "Skip", 146, 494) ;click on next until skip button appears

    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        Delay(1)
        if(FindOrLoseImage(233, 486, 272, 519, , "Skip", 0, failSafeTime)) {
            adbClick_wbb(239, 497)
        } else if(FindOrLoseImage(120, 70, 150, 100, , "Next", 0, failSafeTime)) {
            adbClick_wbb(146, 494) ;146, 494
        } else if(FindOrLoseImage(120, 70, 150, 100, , "Next2", 0, failSafeTime)) {
            adbClick_wbb(146, 494) ;146, 494
        } else if(FindOrLoseImage(121, 465, 140, 485, , "ConfirmPack", 0, failSafeTime)) {
            break
        } else {
			adbClick_wbb(146, 494) ;146, 494
		} 
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for ConfirmPack`n(" . failSafeTime . "/45 seconds)")
        if(failSafeTime > 45)
            restartGameInstance("Stuck at ConfirmPack")
    }
}

getFriendCode() {
    global friendCode
    CreateStatusMessage("Getting friend code...",,,, false)
    Sleep, 2000
    FindImageAndClick(233, 486, 272, 519, , "Skip", 146, 494) ;click on next until skip button appears
    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        Delay(1)
        if(FindOrLoseImage(233, 486, 272, 519, , "Skip", 0, failSafeTime)) {
            adbClick_wbb(239, 497)
        } else if(FindOrLoseImage(120, 70, 150, 100, , "Next", 0, failSafeTime)) {
            adbClick_wbb(146, 494) ;146, 494
        } else if(FindOrLoseImage(120, 70, 150, 100, , "Next2", 0, failSafeTime)) {
            adbClick_wbb(146, 494) ;146, 494
        } else if(FindOrLoseImage(121, 465, 140, 485, , "ConfirmPack", 0, failSafeTime)) {
            break
        } else if(FindOrLoseImage(20, 500, 55, 530, , "Home", 0, failSafeTime)) {
            break
        } else {
            adbclick_wbb(146, 494)
        }
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Home`n(" . failSafeTime . "/45 seconds)")
        if(failSafeTime > 45)
            restartGameInstance("Stuck at Home")
    }
    friendCode := AddFriends(false, true)

    return friendCode
}

SortArraysByProperty(fileNames, fileTimes, packCounts, property, ascending) {
    n := fileNames.MaxIndex()
    
    ; Create an array of indices for sorting
    indices := []
    Loop, %n% {
        indices.Push(A_Index)
    }
    
    ; Sort the indices based on the specified property
    if (property == "time") {
        if (ascending) {
            ; Sort by time ascending
            Sort(indices, Func("CompareIndicesByTimeAsc").Bind(fileTimes))
        } else {
            ; Sort by time descending
            Sort(indices, Func("CompareIndicesByTimeDesc").Bind(fileTimes))
        }
    } else if (property == "packs") {
        if (ascending) {
            ; Sort by pack count ascending
            Sort(indices, Func("CompareIndicesByPacksAsc").Bind(packCounts))
        } else {
            ; Sort by pack count descending
            Sort(indices, Func("CompareIndicesByPacksDesc").Bind(packCounts))
        }
    }
    
    ; Create temporary arrays for sorted values
    sortedFileNames := []
    sortedFileTimes := []
    sortedPackCounts := []
    
    ; Populate sorted arrays based on sorted indices
    Loop, %n% {
        idx := indices[A_Index]
        sortedFileNames.Push(fileNames[idx])
        sortedFileTimes.Push(fileTimes[idx])
        sortedPackCounts.Push(packCounts[idx])
    }
    
    ; Copy sorted values back to original arrays
    Loop, %n% {
        fileNames[A_Index] := sortedFileNames[A_Index]
        fileTimes[A_Index] := sortedFileTimes[A_Index]
        packCounts[A_Index] := sortedPackCounts[A_Index]
    }
}

; Helper function to sort an array using a custom comparison function
Sort(array, compareFunc) {
    QuickSort(array, 1, array.MaxIndex(), compareFunc)
    return array
}

QuickSort(array, left, right, compareFunc) {
    ; Create a manual stack to avoid deep recursion
    stack := []
    stack.Push([left, right])
    
    ; Process all partitions iteratively
    while (stack.Length() > 0) {
        current := stack.Pop()
        currentLeft := current[1]
        currentRight := current[2]
        
        if (currentLeft < currentRight) {
            ; Use middle element as pivot
            pivotIndex := Floor((currentLeft + currentRight) / 2)
            pivotValue := array[pivotIndex]
            
            ; Move pivot to end
            temp := array[pivotIndex]
            array[pivotIndex] := array[currentRight]
            array[currentRight] := temp
            
            ; Move all elements smaller than pivot to the left
            storeIndex := currentLeft
            i := currentLeft
            while (i < currentRight) {
                if (compareFunc.Call(array[i], array[currentRight]) < 0) {
                    ; Swap elements
                    temp := array[i]
                    array[i] := array[storeIndex]
                    array[storeIndex] := temp
                    storeIndex++
                }
                i++
            }
            
            ; Move pivot to its final place
            temp := array[storeIndex]
            array[storeIndex] := array[currentRight]
            array[currentRight] := temp
            
            ; Push the larger partition first (optimization)
            if (storeIndex - currentLeft < currentRight - storeIndex) {
                stack.Push([storeIndex + 1, currentRight])
                stack.Push([currentLeft, storeIndex - 1])
            } else {
                stack.Push([currentLeft, storeIndex - 1])
                stack.Push([storeIndex + 1, currentRight])
            }
        }
    }
}

; Comparison functions for different sorting criteria
CompareIndicesByTimeAsc(times, a, b) {
    timeA := times[a]
    timeB := times[b]
    return timeA < timeB ? -1 : (timeA > timeB ? 1 : 0)
}

CompareIndicesByTimeDesc(times, a, b) {
    timeA := times[a]
    timeB := times[b]
    return timeB < timeA ? -1 : (timeB > timeA ? 1 : 0)
}

CompareIndicesByPacksAsc(packs, a, b) {
    packsA := packs[a]
    packsB := packs[b]
    return packsA < packsB ? -1 : (packsA > packsB ? 1 : 0)
}

CompareIndicesByPacksDesc(packs, a, b) {
    packsA := packs[a]
    packsB := packs[b]
    return packsB < packsA ? -1 : (packsB > packsA ? 1 : 0)
}

CreateAccountList(instance) {
    global injectSortMethod, deleteMethod, winTitle, verboseLogging, checkWPthanks
    
    ; Clean up stale used accounts first
    CleanupUsedAccounts()
    CleanupWPMetadata() ; clean up wonderpick testing account metadata
    
    saveDir := A_ScriptDir "\..\Accounts\Saved\" . instance
    outputTxt := saveDir . "\list.txt"
    outputTxt_current := saveDir . "\list_current.txt"
    lastGeneratedFile := saveDir . "\list_last_generated.txt"
    
    ; Check if we need to regenerate the lists
    needRegeneration := false
    forceRegeneration := false
    
    ; First check: Do list files exist and are they not empty?
    if (!FileExist(outputTxt) || !FileExist(outputTxt_current)) {
        needRegeneration := true
        LogToFile("List files don't exist, regenerating...")
    } else {
        ; Check if current list is empty or nearly empty
        FileRead, currentListContent, %outputTxt_current%
        currentListLines := StrSplit(Trim(currentListContent), "`n", "`r")
        eligibleAccountsInList := 0
        
        ; Count non-empty lines
        for index, line in currentListLines {
            if (StrLen(Trim(line)) > 5) {
                eligibleAccountsInList++
            }
        }
        
        ; If list is empty or has very few accounts, force regeneration
        if (eligibleAccountsInList <= 1) {
            LogToFile("Current list is empty or nearly empty, forcing regeneration...")
            forceRegeneration := true
            needRegeneration := true
        } else {
            ; Check time-based regeneration
            lastGenTime := 0
            if (FileExist(lastGeneratedFile)) {
                FileRead, lastGenTime, %lastGeneratedFile%
            }
            
            timeDiff := A_Now
            EnvSub, timeDiff, %lastGenTime%, Minutes
            
            regenerationInterval := 60  ; in minutes
            if (timeDiff > regenerationInterval || !lastGenTime) {
                needRegeneration := true
            } else {
                return
            }
        }
    }
    
    if (!needRegeneration) {
        return
    }
    
    ; If we're forcing regeneration due to empty lists, clear used accounts log
    if (forceRegeneration) {
        usedAccountsLog := saveDir . "\used_accounts.txt"
        LogToFile("Forcing regeneration - clearing used accounts log to recover all accounts")
        
        ; Backup the used accounts log before clearing
        if (FileExist(usedAccountsLog)) {
            backupLog := saveDir . "\used_accounts_backup_" . A_Now . ".txt"
            FileCopy, %usedAccountsLog%, %backupLog%
            LogToFile("Backed up used accounts log to: " . backupLog)
        }
        
        ; Clear the used accounts log
        FileDelete, %usedAccountsLog%
        LogToFile("Cleared used accounts log - all accounts now available again")
    }

    if (!injectSortMethod)
        injectSortMethod := "ModifiedAsc"
    
    parseInjectType := "Inject 13P+"  ; Default
    
    ; Determine injection type and pack ranges
    if (deleteMethod = "Inject 13P+") {
        parseInjectType := "Inject 13P+"
        minPacks := 0
        maxPacks := 9999
    }
    else if (deleteMethod = "Inject Missions") {
        parseInjectType := "Inject Missions"
        minPacks := 0
        maxPacks := 38
    }
    else if (deleteMethod = "Inject Wonderpick 96P+") {
        parseInjectType := "Inject Wonderpick 96P+"
        minPacks := 35
        maxPacks := 9999
    }
    
    ; Load used accounts from cleaned up log (will be empty if we just cleared it)
    usedAccountsLog := saveDir . "\used_accounts.txt"
    usedAccounts := {}
    if (FileExist(usedAccountsLog)) {
        FileRead, usedAccountsContent, %usedAccountsLog%
        Loop, Parse, usedAccountsContent, `n, `r
        {
            if (A_LoopField) {
                parts := StrSplit(A_LoopField, "|")
                if (parts.Length() >= 1) {
                    usedAccounts[parts[1]] := 1
                }
            }
        }
    }
    
    ; Delete existing list files before regenerating
    if FileExist(outputTxt)
        FileDelete, %outputTxt%
    if FileExist(outputTxt_current)
        FileDelete, %outputTxt_current%
    
    ; Create arrays to store files with their timestamps
    fileNames := []
    fileTimes := []
    packCounts := []
    wFlagFiles := []  ; Separate array for W flag files
    
    ; First pass: gather W flag files that are ready for checking
    if (checkWPthanks = 1 && deleteMethod = "Inject Wonderpick 96P+") {
        Loop, %saveDir%\*.xml {
            if (InStr(A_LoopFileName, "W")) {
                xml := saveDir . "\" . A_LoopFileName
                
                ; Get file modification time
                modTime := ""
                FileGetTime, modTime, %xml%, M
                
                ; Calculate minutes difference
                minutesDiff := A_Now
                timeVar := modTime
                EnvSub, minutesDiff, %timeVar%, Minutes
                
                if (InStr(A_LoopFileName, "W2")) {
                    ; Second check - wait 12 hours (720 minutes)
                    if (minutesDiff >= 720) {
                        wFlagFiles.Push(A_LoopFileName)
                    }
                } else {
                    ; First check - wait 30 minutes
                    if (minutesDiff >= 30) {
                        wFlagFiles.Push(A_LoopFileName)
                    }
                }
            }
        }
    }
    
    ; Second pass: gather all other eligible files with their timestamps
    Loop, %saveDir%\*.xml {
        xml := saveDir . "\" . A_LoopFileName
        
        ; Skip W flag files as they're handled separately
        if (InStr(A_LoopFileName, "W")) {
            continue
        }
        
        ; Skip if this account was recently used (unless we just cleared the log)
        if (usedAccounts.HasKey(A_LoopFileName)) {
            if (verboseLogging)
                LogToFile("Skipping recently used account: " . A_LoopFileName)
            continue
        }
        
        ; Get file modification time
        modTime := ""
        FileGetTime, modTime, %xml%, M
        
        ; Calculate hours difference properly
        hoursDiff := A_Now
        timeVar := modTime
        EnvSub, hoursDiff, %timeVar%, Hours

        ; Always maintain strict age requirements - never relax them
        if (hoursDiff < 24) {
            if (verboseLogging)
                LogToFile("Skipping account less than 24 hours old: " . A_LoopFileName . " (age: " . hoursDiff . " hours)")
            continue
        }

        ; Check if account has "T" flag and needs more time (always 5 days)
        ; BUT skip this check if account also has "W" flag (W takes precedence)
        if(InStr(A_LoopFileName, "(") && InStr(A_LoopFileName, "T") && !InStr(A_LoopFileName, "W")) {
            if(hoursDiff < 5*24) {  ; Always 5 days for T-flagged accounts
                if (verboseLogging)
                    LogToFile("Skipping account with T flag (testing): " . A_LoopFileName . " (age: " . hoursDiff . " hours, needs 5 days)")
                continue
            }
        }
        
        ; Extract pack count from filename
        packCount := 0
        
        ; Extract the number before P
        if (RegExMatch(A_LoopFileName, "^(\d+)P", packMatch)) {
            packCount := packMatch1 + 0  ; Force numeric conversion
        } else {
            packCount := 10  ; Default for unrecognized formats
            if (verboseLogging)
                LogToFile("Unknown filename format: " . A_LoopFileName . ", assigned default pack count: 10")
        }
        
        ; Check if pack count fits the current injection range
        if (packCount < minPacks || packCount > maxPacks) {
            if (verboseLogging)
                LogToFile("  - SKIPPING: " . A_LoopFileName . " - Pack count " . packCount . " outside range " . minPacks . "-" . maxPacks)
            continue
        }
        
        ; Store filename, modification time, and pack count
        fileNames.Push(A_LoopFileName)
        fileTimes.Push(modTime)
        packCounts.Push(packCount)
        if (verboseLogging)
            LogToFile("  - KEEPING: " . A_LoopFileName . " - Pack count " . packCount . " inside range " . minPacks . "-" . maxPacks . " (age: " . hoursDiff . " hours)")
    }
    
    ; Log counts
    totalEligible := (fileNames.MaxIndex() ? fileNames.MaxIndex() : 0)
    totalWFlags := (wFlagFiles.MaxIndex() ? wFlagFiles.MaxIndex() : 0)
    
    if (forceRegeneration) {
        LogToFile("FORCED REGENERATION: Found " . totalEligible . " eligible files + " . totalWFlags . " W flag files (cleared used accounts, maintained strict age requirements)")
    } else {
        LogToFile("Found " . totalEligible . " eligible files + " . totalWFlags . " W flag files (>= 24 hours old, not recently used, packs: " . minPacks . "-" . maxPacks . ")")
    }
    
    ; Sort regular files based on selected method
    if (fileNames.MaxIndex() > 0) {
        sortMethod := (injectSortMethod) ? injectSortMethod : "ModifiedAsc"
        
        if (sortMethod == "ModifiedAsc") {
            SortArraysByProperty(fileNames, fileTimes, packCounts, "time", 1)
        } else if (sortMethod == "ModifiedDesc") {
            SortArraysByProperty(fileNames, fileTimes, packCounts, "time", 0)
        } else if (sortMethod == "PacksAsc") {
            SortArraysByProperty(fileNames, fileTimes, packCounts, "packs", 1)
        } else if (sortMethod == "PacksDesc") {
            SortArraysByProperty(fileNames, fileTimes, packCounts, "packs", 0)
        } else {
            ; Default to ModifiedAsc if unknown sort method
            SortArraysByProperty(fileNames, fileTimes, packCounts, "time", 1)
        }
    }
    
    ; Prepare content for output files - W flag files first, then regular files
    outputContent := ""
    
    ; Add W flag files first (highest priority)
    if (wFlagFiles.MaxIndex() > 0) {
        For i, fileName in wFlagFiles {
            outputContent .= fileName . "`n"
            if (verboseLogging && i <= 5)
                LogToFile("  W-" . i . ": " . fileName . " (WP Thanks Check)")
        }
    }
    
    ; Add regular files
    if (fileNames.MaxIndex() > 0) {
        For i, fileName in fileNames {
            outputContent .= fileName . "`n"
            
            ; Log first 10 files for verification
            if (i <= 10) {
                if(verboseLogging) {
                    FormatTime, fileTimeStr, % fileTimes[i], yyyy-MM-dd HH:mm:ss
                    LogToFile("  " . i . ": " . fileName . " (Modified: " . fileTimeStr . ", Packs: " . packCounts[i] . ")")
                }
            } else if (i == 11) {
                if(verboseLogging)
                    LogToFile("  ... (showing first 10 files only)")
            }
        }
    }
    
    ; Write sorted files to output files
    if (outputContent != "") {
        FileAppend, %outputContent%, %outputTxt%
        FileAppend, %outputContent%, %outputTxt_current%
        
        LogToFile("Successfully wrote " . (totalEligible + totalWFlags) . " files to lists (" . totalWFlags . " W flags + " . totalEligible . " regular)")
    } else {
        ; Create empty files to prevent repeated regeneration attempts
        FileAppend, "", %outputTxt%
        FileAppend, "", %outputTxt_current%
        LogToFile("Created empty list files")
    }
    
    ; Create a file that tracks when the list was last regenerated
    FileDelete, % lastGeneratedFile
    FileAppend, % A_Now, % lastGeneratedFile
    LogToFile("List generation completed at: " . A_Now)
    
    ; Log summary statistics
    if (totalEligible > 0 || totalWFlags > 0) {
        LogToFile("=== ACCOUNT LIST SUMMARY ===")
        LogToFile("Total eligible accounts: " . totalEligible)
        LogToFile("W flag accounts ready: " . totalWFlags)
        LogToFile("Injection method: " . parseInjectType)
        LogToFile("Pack range: " . minPacks . "-" . maxPacks)
        LogToFile("Sort method: " . sortMethod)
        LogToFile("Used accounts excluded: " . usedAccounts.Count())
        LogToFile("Forced regeneration: " . (forceRegeneration ? "Yes" : "No"))
        LogToFile("============================")
    }
}

checkShouldDoMissions() {
    global beginnerMissionsDone, deleteMethod, injectMethod, loadedAccount, friendIDs, friendID, accountOpenPacks, maxAccountPackNum, verboseLogging
    
    if (beginnerMissionsDone) {
        return false
    }
    
    if (deleteMethod = "Create Bots (13P)") {
        return (!friendIDs && friendID = "" && accountOpenPacks < maxAccountPackNum) || (friendIDs || friendID != "")
    }
    else if (deleteMethod = "Inject Missions") {
        IniRead, skipMissions, %A_ScriptDir%\..\Settings.ini, UserSettings, skipMissionsInjectMissions, 0
        if (skipMissions = 1) {
            if(verboseLogging)
                LogToFile("Skipping missions for Inject Missions method (user setting)")
            return false
        }
        if(verboseLogging)
            LogToFile("Executing missions for Inject Missions method (user setting enabled)")
        return true
    }
    else if (deleteMethod = "Inject 13P+" || deleteMethod = "Inject Wonderpick 96P+") {
        if(verboseLogging)
            LogToFile("Skipping missions for " . deleteMethod . " method - missions only run for 'Inject Missions'")
        return false
    }
    else {
        ; For non-injection methods (like regular delete methods)
        return (!friendIDs && friendID = "" && accountOpenPacks < maxAccountPackNum) || (friendIDs || friendID != "")
    }
}

DoWonderPickOnly() {

    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        adbClick_wbb(80, 460)
        
        if(FindOrLoseImage(240, 80, 265, 100, , "WonderPick", 1, failSafeTime)) {
            clickButton := FindOrLoseImage(100, 367, 190, 480, 100, "Button", 0, failSafeTime)
            if(clickButton) {
                StringSplit, pos, clickButton, `,  ; Split at ", "
                    ; Adjust pos2 if scaleParam is 287 for 100%
                    if (scaleParam = 287) {
                        pos2 += 5
                    }
                    adbClick_wbb(pos1, pos2)
                Delay(3)
            }
            if(FindOrLoseImage(160, 330, 200, 370, , "Card", 0, failSafeTime))
                break
        }
        Delay(1)
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for WonderPick`n(" . failSafeTime . "/45 seconds)")
    }
    Sleep, 300
    if(slowMotion)
        Sleep, 3000
    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        adbClick_wbb(183, 350) ; click card
        if(FindOrLoseImage(160, 330, 200, 370, , "Card", 1, failSafeTime)) {
            break
        }
        Delay(1)
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Card`n(" . failSafeTime . "/45 seconds)")
    }
    failSafe := A_TickCount
    failSafeTime := 0
	;TODO thanks and wonder pick 5 times for missions
    Loop {
        adbClick_wbb(146, 494)
        if(FindOrLoseImage(233, 486, 272, 519, , "Skip", 0, failSafeTime) || FindOrLoseImage(240, 80, 265, 100, , "WonderPick", 0, failSafeTime))
            break
        if(FindOrLoseImage(160, 330, 200, 370, , "Card", 0, failSafeTime)) {
            adbClick_wbb(183, 350) ; click card
        }
        delay(1)
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Shop`n(" . failSafeTime . "/45 seconds)")
    }
	
    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        Delay(2)
        if(FindOrLoseImage(191, 393, 211, 411, , "Shop", 0, failSafeTime))
            break
        else if(FindOrLoseImage(233, 486, 272, 519, , "Skip", 0, failSafeTime))
            adbClick_wbb(239, 497)
        else
            adbInputEvent("111") ;send ESC
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Shop`n(" . failSafeTime . "/45 seconds)")
    }
}

DoWonderPick() {
    FindImageAndClick(191, 393, 211, 411, , "Shop", 40, 515) ;click until at main menu
    FindImageAndClick(240, 80, 265, 100, , "WonderPick", 59, 429) ;click until in wonderpick Screen
	
	DoWonderPickOnly()
	
    FindImageAndClick(2, 85, 34, 120, , "Missions", 261, 478, 500)
    ;FindImageAndClick(130, 170, 170, 205, , "WPMission", 150, 286, 1000)
    FindImageAndClick(120, 185, 150, 215, , "FirstMission", 150, 286, 1000)
    failSafe := A_TickCount
    failSafeTime := 0
    Loop {
        Delay(1)
        adbClick_wbb(139, 424)
        Delay(1)
        clickButton := FindOrLoseImage(145, 447, 258, 480, 80, "Button", 0, failSafeTime)
        if(clickButton) {
            adbClick_wbb(110, 369)
        }
        else if(FindOrLoseImage(191, 393, 211, 411, , "Shop", 1, failSafeTime))
            ;adbInputEvent("111") ;send ESC
			adbClick_wbb(139, 492)
        else
            break
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for WonderPick`n(" . failSafeTime . "/45 seconds)")
    }
    return true
}

getChangeDateTime() {
	offset := A_Now
	currenttimeutc := A_NowUTC
	EnvSub, offset, %currenttimeutc%, Hours   ;offset from local timezone to UTC

    resetTime := SubStr(A_Now, 1, 8) "060000" ;today at 6am [utc] zero seconds is the reset time at UTC
	resetTime += offset, Hours                ;reset time in local timezone

	;find the closest reset time
	currentTime := A_Now
	timeToReset := resetTime
	EnvSub, timeToReset, %currentTime%, Hours
	if(timeToReset > 12) {
		resetTime += -1, Days
	} else if (timeToReset < -12) {
		resetTime += 1, Days
	}

    return resetTime
}

getMetaData() {
    beginnerMissionsDone := 0
    soloBattleMissionDone := 0
    intermediateMissionsDone := 0
    specialMissionsDone := 0
    accountHasPackInTesting := 0

    ; check if account file has metadata information
    if(InStr(accountFileName, "(")) {
        accountFileNameParts1 := StrSplit(accountFileName, "(")  ; Split at (
        if(InStr(accountFileNameParts1[2], ")")) {
            ; has metadata information
            accountFileNameParts2 := StrSplit(accountFileNameParts1[2], ")")  ; Split at )
            metadata := accountFileNameParts2[1]
            if(InStr(metadata, "B"))
                beginnerMissionsDone := 1
            if(InStr(metadata, "S"))
                soloBattleMissionDone := 1
            if(InStr(metadata, "I"))
                intermediateMissionsDone := 1
            if(InStr(metadata, "X"))
                specialMissionsDone := 1
            if(InStr(metadata, "T")) {
                saveDir := A_ScriptDir "\..\Accounts\Saved\" . winTitle
                accountFile := saveDir . "\" . accountFileName
                FileGetTime, fileTime, %accountFile%, M  ; M for modification time
                EnvSub, fileTime, %A_Now%, hours
                hoursDiff := Abs(fileTime)
                if(hoursDiff >= 5*24) {
                    accountHasPackInTesting := 0
                    setMetaData()
                } else {
                    accountHasPackInTesting := 1
                }
            }
        }
    }
    
    if(resetSpecialMissionsDone)
        specialMissionsDone := 0
}

setMetaData() {
    hasMetaData := 0
    NamePartRightOfMeta := ""
    NamePartLeftOfMeta := ""
    
    ; check if account file has metadata information
    if(InStr(accountFileName, "(")) {
        accountFileNameParts1 := StrSplit(accountFileName, "(")  ; Split at (
        NamePartLeftOfMeta := accountFileNameParts1[1]
        if(InStr(accountFileNameParts1[2], ")")) {
            ; has metadata information
            accountFileNameParts2 := StrSplit(accountFileNameParts1[2], ")")  ; Split at )
            NamePartRightOfMeta := accountFileNameParts2[2]
            ;metadata := accountFileNameParts2[1]
            
            hasMetaData := 1
        }
    }
    
    metadata := ""
    if(beginnerMissionsDone)
        metadata .= "B"
    if(soloBattleMissionDone)
        metadata .= "S"
    if(intermediateMissionsDone)
        metadata .= "I"
    if(specialMissionsDone)
        metadata .= "X"
    if(accountHasPackInTesting)
        metadata .= "T"
    
    ; Remove parentheses if no flags remain, helpful if there is only a T flag or manual removal of X flag
    if(hasMetaData) {
        if (metadata = "") {
            AccountNewName := NamePartLeftOfMeta . NamePartRightOfMeta
        } else {
            AccountNewName := NamePartLeftOfMeta . "(" . metadata . ")" . NamePartRightOfMeta
        }
    } else {
        if (metadata = "") {
            NameAndExtension := StrSplit(accountFileName, ".")  
            AccountNewName := NameAndExtension[1] . ".xml"
        } else {
            NameAndExtension := StrSplit(accountFileName, ".")  
            AccountNewName := NameAndExtension[1] . "(" . metadata . ").xml"
        }
    }
    
    saveDir := A_ScriptDir "\..\Accounts\Saved\" . winTitle
    accountFile := saveDir . "\" . accountFileName
    accountNewFile := saveDir . "\" . AccountNewName
    FileMove, %accountFile% , %accountNewFile% 
    accountFileName := AccountNewName
}

SpendAllHourglass() {
    GoToMain()
    GetAllRewards(false, true)
    GoToMain()    

    SelectPack("HGPack")
    if(cantOpenMorePacks)
        return
    
    PackOpening()
    if(cantOpenMorePacks || (!friendIDs && friendID = "" && accountOpenPacks >= maxAccountPackNum))
        return
    
    ; Keep opening packs until we can't anymore
    while (!cantOpenMorePacks && (friendIDs || friendID != "" || accountOpenPacks < maxAccountPackNum)) {
        if(packMethod) {
            ; For packMethod=true: remove/re-add friends between each pack
            friendsAdded := AddFriends(true)  ; true parameter removes and re-adds friends
            SelectPack("HGPack")
            if(cantOpenMorePacks)
                break
            PackOpening()  ; Use PackOpening since we just selected the pack
        } else {
            ; For packMethod=false: direct hourglass opening
            HourglassOpening(true)
        }
        
        if(cantOpenMorePacks || (!friendIDs && friendID = "" && accountOpenPacks >= maxAccountPackNum))
            break
    }
}

; For Special Missions 2025
GetEventRewards(frommain := true){
    swipeSpeed := 300
    adbSwipeX3 := Round(211 / 277 * 535)
    adbSwipeX4 := Round(11 / 277 * 535)
    adbSwipeY2 := Round((453 - 44) / 489 * 960)
    adbSwipeParams2 := adbSwipeX3 . " " . adbSwipeY2 . " " . adbSwipeX4 . " " . adbSwipeY2 . " " . swipeSpeed
    if (frommain){
        FindImageAndClick(2, 85, 34, 120, , "Missions", 261, 478, 500)
    }
    Delay(4)
    
    LevelUp()
    
    if(setSpeed > 1) {
        FindImageAndClick(25, 145, 70, 170, , "Platin", 18, 109, 2000) ; click mod settings
        FindImageAndClick(9, 170, 25, 190, , "One", 26, 180) ; click mod settings
        Delay(1)
    }
    failSafe := A_TickCount
    failSafeTime := 0
    Loop{
        adbSwipe(adbSwipeParams2)
        Sleep, 10
        if (FindOrLoseImage(225, 444, 272, 470, , "Premium", 0, failSafeTime)){
            if(setSpeed > 1) {
                if(setSpeed = 3)
                        FindImageAndClick(182, 170, 194, 190, , "Three", 187, 180) ; click mod settings
                else
                        FindImageAndClick(100, 170, 113, 190, , "Two", 107, 180) ; click mod settings
            }
                ; adbClick_wbb(41, 296)
                break
            }
        failSafeTime := (A_TickCount - failSafe) // 1000
        CreateStatusMessage("Waiting for Trace`n(" . failSafeTime . "/45 seconds)")
        Delay(1)
    }
    ; pick ONE of these two click locations based upon which events are currently going on.
    ; adbClick_wbb(120, 465) ; used to click the middle mission button
    adbClick_wbb(25, 465) ;used to click the left-most mission button
    failSafe := A_TickCount
    failSafeTime := 0
    Loop{
        Delay(5)
        adbClick_wbb(172, 427) ;clicks complete all and ok
        Delay(5)
        adbClick_wbb(152, 464) ;when to many rewards ok button goes lower
        if FindOrLoseImage(244, 406, 273, 449, , "GotAllMissions", 0, 0) {
            break
        }
        else if (failSafeTime > 60){
            GotRewards := false
            break
        }
        failSafeTime := (A_TickCount - failSafe) // 1000
    }
    GoToMain()
}

GetAllRewards(tomain := true, dailies := false) {
    FindImageAndClick(2, 85, 34, 120, , "Missions", 261, 478, 500)
    Delay(4)
    failSafe := A_TickCount
    failSafeTime := 0
    GotRewards := true
    if(dailies){
        FindImageAndClick(37, 130, 64, 156, , "DailyMissions", 165, 465, 500)
    }
    Loop {
        Delay(2)
        adbClick(174, 427)
        adbClick(174, 427) ; changed 2px right & added 2nd click
        Delay(1) ; new Delay
        if(dailies) {
            FindImageAndClick(73, 151, 210, 173, , "CollectDailies", 250, 135, 500)
        }
        
        if(FindOrLoseImage(244, 406, 273, 449, , "GotAllMissions", 0, 0)) {
            break
        }
        else if (failSafeTime > 20) {
            GotRewards := false
            break
        }
        failSafeTime := (A_TickCount - failSafe) // 1000
    }
    if (tomain) {
        GoToMain()
    }
}

GoToMain(fromSocial := false) {
    failSafe := A_TickCount
    failSafeTime := 0
    if(!fromSocial) {
        Delay(2)
        Loop {
            Delay(3) ;increase this delay if you see "close app" on home page
            if(FindOrLoseImage(191, 393, 211, 411, , "Shop", 0, failSafeTime)) {
                break
            }
            else
                adbInputEvent("111") ;send ESC
            failSafeTime := (A_TickCount - failSafe) // 1000
            CreateStatusMessage("Waiting for Shop`n(" . failSafeTime . "/45 seconds)")
        }
    }
    else {
        FindImageAndClick(120, 500, 155, 530, , "Social", 143, 518)
        FindImageAndClick(191, 393, 211, 411, , "Shop", 20, 515, 500) ;click until at main menu
    }
}

;levelUp()
;FindOrLoseImage(118, 167, 167, 203, , "unlocked", 0, failSafeTime)
;FindImageAndClick(118, 167, 167, 203, , "unlocked", 144, 396, sleepTime)
;adbClick_wbb(144, 396)

;FindOrLoseImage(53, 280, 81, 306, , "unlockdisplayboard", 0, failSafeTime)
;FindImageAndClick(53, 280, 81, 306, , "unlockdisplayboard", 137, 362, sleepTime)
;adbClick_wbb(137, 362)
^e::
    pToken := Gdip_Startup()
    Screenshot_dev()
return

SaveWPMetadata(accountFileName, username, friendCode) {
    global winTitle
    
    ; Use the instance folder where accounts are actually loaded from
    saveDir := A_ScriptDir "\..\Accounts\Saved\" . winTitle
    metadataFile := saveDir . "\wp_metadata.txt"
    
    ; Read existing metadata
    existingMetadata := ""
    if (FileExist(metadataFile)) {
        FileRead, existingMetadata, %metadataFile%
    }
    
    ; Prepare new entry
    newEntry := accountFileName . "|" . username . "|" . friendCode
    
    ; Check if entry already exists for this account
    updatedMetadata := ""
    entryExists := false
    
    Loop, Parse, existingMetadata, `n, `r
    {
        if (A_LoopField = "") {
            continue
        }
        
        parts := StrSplit(A_LoopField, "|")
        if (parts.Length() >= 3 && parts[1] = accountFileName) {
            ; Update existing entry
            updatedMetadata .= newEntry . "`n"
            entryExists := true
        } else {
            ; Keep existing entry
            updatedMetadata .= A_LoopField . "`n"
        }
    }
    
    ; Add new entry if it didn't exist
    if (!entryExists) {
        updatedMetadata .= newEntry . "`n"
    }
    
    ; Write updated metadata
    FileDelete, %metadataFile%
    FileAppend, %updatedMetadata%, %metadataFile%
    
    LogToFile("Saved WP metadata to centralized file: " . accountFileName . " (User: " . username . ", FC: " . friendCode . ")")
}

LoadWPMetadata(accountFileName, ByRef username, ByRef friendCode) {
    global winTitle
    
    ; Use the instance folder where accounts are actually loaded from
    saveDir := A_ScriptDir "\..\Accounts\Saved\" . winTitle
    metadataFile := saveDir . "\wp_metadata.txt"
    
    ; Default values
    username := "Unknown"
    friendCode := "Unknown"
    
    if (FileExist(metadataFile)) {
        FileRead, metadataContent, %metadataFile%
        
        ; Parse the content to find the specific account
        Loop, Parse, metadataContent, `n, `r
        {
            if (A_LoopField = "") {
                continue
            }
            
            parts := StrSplit(A_LoopField, "|")
            if (parts.Length() >= 3 && parts[1] = accountFileName) {
                username := parts[2]
                friendCode := parts[3]
                LogToFile("Loaded WP metadata from centralized file: " . accountFileName . " (User: " . username . ", FC: " . friendCode . ")")
                return
            }
        }
        
        LogToFile("No WP metadata found for account: " . accountFileName . " in centralized file")
    } else {
        LogToFile("No centralized WP metadata file found: " . metadataFile)
    }
}

CheckWonderPickThanks() {
    global accountFileName, checkWPthanks, wpThanksSavedUsername, wpThanksSavedFriendCode
    global discordWebhookURL, discordUserId, scriptName, packsInPool, openPack, scaleParam
    global username, friendCode, isCurrentlyDoingWPCheck
    
    if (!InStr(accountFileName, "W")) {
        return false  ; Not a W flag account
    }
    
    ; Set flag to indicate we're actively doing a WP check
    isCurrentlyDoingWPCheck := true
    
    isSecondCheck := InStr(accountFileName, "W2")
    checkStage := isSecondCheck ? "FINAL" : "FIRST"
    
    CreateStatusMessage("Checking WonderPick Thanks (" . checkStage ") for account...",,,, false)
    LogToFile("Starting WonderPick " . checkStage . " check for: " . accountFileName)
    
    ; Load username and friend code from centralized metadata
    LoadWPMetadata(accountFileName, wpThanksSavedUsername, wpThanksSavedFriendCode)
    
    ; Set speed to 3x
    FindImageAndClick(25, 145, 70, 170, , "Platin", 18, 109, 2000)
    FindImageAndClick(182, 170, 194, 190, , "Three", 187, 180)
    Delay(1)
    adbClick_wbb(41, 296)
    Delay(1)
    
    ; Navigate to gifts/mail screen with timeout protection
    try {
        FindImageAndClick(240, 70, 270, 110, , "Mail", 34, 518, 1000)
        Delay(3)
        FindImageAndClick(164, 431, 224, 460, , "ClaimAll", 247, 93, 1000)
        Delay(20)
    } catch e {
        ; If anything fails during navigation, handle gracefully
        LogToFile("WP Thanks check failed during navigation for: " . accountFileName . " - " . e.message)
        RemoveWFlagFromAccount()
        SendWPStuckWarning("Navigation Error")
        isCurrentlyDoingWPCheck := false  ; Clear flag before returning
        return true
    }
    
    thanksFound := false
    screenshotPath := ""
    
    if(FindOrLoseImage(25, 137, 57, 161, 140, "ShopTicket", 0)) {
        thanksFound := true
        LogToFile("ShopTicket found")
        
        ; Take screenshot BEFORE clicking for LIVE packs
        screenshotPath := Screenshot("WP_THANKS_LIVE", "WonderPickThanks")
        
        adbClick(212, 427)
    }
    
    if (thanksFound) {
        CreateStatusMessage("Shop Ticket gift found! Pack is likely LIVE",,,, false)
        LogToFile("Shop Ticket found for account: " . accountFileName . " (User: " . wpThanksSavedUsername . ", FC: " . wpThanksSavedFriendCode . ")")
        Delay(20)
        
        ; For LIVE packs, remove W flag completely (no second check needed)
        RemoveWFlagFromAccount()
        LogToFile("LIVE pack found, removed W flag completely from: " . accountFileName)
        
    } else {
        CreateStatusMessage("Shop Ticket not found. Pack is likely DEAD",,,, false)
        LogToFile("No WonderPick Thanks found for account: " . accountFileName . " (User: " . wpThanksSavedUsername . ", FC: " . wpThanksSavedFriendCode . ")")
        Delay(5)
        
        ; Handle flag conversion or removal for DEAD packs
        if (isSecondCheck) {
            ; This was the final check - remove W2 flag completely
            RemoveWFlagFromAccount()
            LogToFile("Final WonderPick check completed, removed W2 flag from: " . accountFileName)
        } else {
            ; This was the first check - convert W to W2 for second check
            ConvertWToW2Flag()
            LogToFile("First WonderPick check completed, converted W to W2 flag for: " . accountFileName)
        }
    }
    
    ; Send Discord notification
    SendWPThanksReport(thanksFound, checkStage, screenshotPath)
    
    ; Clear flag before returning
    isCurrentlyDoingWPCheck := false
    
    return true
}

SendWPStuckWarning(stuckAt) {
    global wpThanksSavedUsername, wpThanksSavedFriendCode, accountFileName, scriptName
    global discordWebhookURL, discordUserId
    
    displayUsername := (wpThanksSavedUsername != "") ? wpThanksSavedUsername : "Unknown"
    displayFriendCode := (wpThanksSavedFriendCode != "") ? wpThanksSavedFriendCode : "Unknown"
    
    discordMessage := "**[WP CHECK STUCK]** " . displayUsername . " " . displayFriendCode . " - Bot got stuck at '" . stuckAt . "' during WonderPick thanks check. Removed W flag and continuing. Please check manually if this account received WonderPick thanks. Account: " . accountFileName
    
    ; Send with ping to alert user
    LogToDiscord(discordMessage, "", true, "", "", discordWebhookURL, discordUserId)
    LogToFile("WP thanks check stuck warning sent for: " . accountFileName . " (stuck at: " . stuckAt . ")")
}

ConvertWToW2Flag() {
    global accountFileName, winTitle
    
    saveDir := A_ScriptDir "\..\Accounts\Saved\" . winTitle
    oldFilePath := saveDir . "\" . accountFileName
    
    ; Check if file exists and has W flag (but not W2)
    if (!FileExist(oldFilePath) || !InStr(accountFileName, "W") || InStr(accountFileName, "W2")) {
        return
    }
    
    ; Convert W to W2 in the metadata
    newFileName := StrReplace(accountFileName, "W", "W2")
    
    ; Rename the file
    if (newFileName != accountFileName) {
        newFilePath := saveDir . "\" . newFileName
        FileMove, %oldFilePath%, %newFilePath%
        LogToFile("Converted W to W2 flag: " . accountFileName . " -> " . newFileName)
        accountFileName := newFileName
    }
}

SendWPThanksReport(thanksFound, checkStage := "FIRST", screenshotPath := "") {
    global wpThanksSavedUsername, wpThanksSavedFriendCode, accountFileName, scriptName
    global discordWebhookURL, discordUserId
    
    ; Use the freshly obtained values
    displayUsername := (wpThanksSavedUsername != "") ? wpThanksSavedUsername : "Unknown"
    displayFriendCode := (wpThanksSavedFriendCode != "") ? wpThanksSavedFriendCode : "Unknown"
    
    if (thanksFound) {
        ; LIVE pack messaging - don't include <@> in message since LogToDiscord handles pinging
        discordMessage := "**[LIVE]** " . displayUsername . " " . displayFriendCode . " " . accountFileName
        
        ; Send with screenshot and ping user (LogToDiscord will handle the @mention)
        LogToDiscord(discordMessage, screenshotPath, true, "", "", discordWebhookURL, discordUserId)
    } else {
        ; DEAD pack messaging - don't include <@> in message
        if (checkStage = "FIRST") {
            discordMessage := displayUsername . " " . displayFriendCode . " did not receive any wonderpick thanks. [LIKELY DEAD] - checking again in 12 hours to confirm."
        } else {
            discordMessage := displayUsername . " " . displayFriendCode . " did not receive any wonderpick thanks after 12 hours. [LIKELY DEAD] - will not be checked again."
        }
        
        ; Send without pinging (empty user ID parameter)
        LogToDiscord(discordMessage, "", true, "", "", discordWebhookURL, "")
    }
    
    status := thanksFound ? "LIVE" : "DEAD"
    LogToFile("WP Thanks " . checkStage . " report sent: " . status . " for " . accountFileName . " (Username: " . displayUsername . ", FriendCode: " . displayFriendCode . ")")
}

RemoveWFlagFromAccount() {
    global accountFileName, winTitle
    
    saveDir := A_ScriptDir "\..\Accounts\Saved\" . winTitle
    oldFilePath := saveDir . "\" . accountFileName
    
    ; Check if file exists and has any W flag
    if (!FileExist(oldFilePath) || !InStr(accountFileName, "W")) {
        LogToFile("RemoveWFlagFromAccount: No W flag found or file doesn't exist: " . accountFileName)
        return
    }
    
    ; Remove W from the metadata
    newFileName := accountFileName
    if (InStr(accountFileName, "(")) {
        ; Extract metadata and remove W or W2
        parts1 := StrSplit(accountFileName, "(")
        leftPart := parts1[1]
        
        if (InStr(parts1[2], ")")) {
            parts2 := StrSplit(parts1[2], ")")
            metadata := parts2[1]
            rightPart := parts2[2]
            
            ; Remove both W2 and W from metadata
            newMetadata := StrReplace(metadata, "W2", "")
            newMetadata := StrReplace(newMetadata, "W", "")
            
            ; Reconstruct filename
            if (newMetadata = "") {
                newFileName := leftPart . rightPart
            } else {
                newFileName := leftPart . "(" . newMetadata . ")" . rightPart
            }
        }
    }
    
    ; Rename the file if it changed
    if (newFileName != accountFileName) {
        newFilePath := saveDir . "\" . newFileName
        FileMove, %oldFilePath%, %newFilePath%
        LogToFile("Removed W flag: " . accountFileName . " -> " . newFileName)
        accountFileName := newFileName
    } else {
        LogToFile("RemoveWFlagFromAccount: No changes needed for: " . accountFileName)
    }
}

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Find Card Count and OCR Helper Functions
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FindPackStats() {
    global adbShell, scriptName, ocrLanguage, loadDir

	failSafe := A_TickCount
	failSafeTime := 0
    ; Click for hamburger menu and wait for profile
    Loop {
        adbClick(240, 499)
        if(FindOrLoseImage(230, 120, 260, 150, , "UserProfile", 0, failSafeTime)) {
            break
        } else {
            clickButton := FindOrLoseImage(75, 340, 195, 530, 80, "Button", 0)
            if(clickButton) {
                StringSplit, pos, clickButton, `,  ; Split at ", "
                if (scaleParam = 287) {
                    pos2 += 5
                }
                adbClick(pos1, pos2)
			}
		}
		levelUp()
        Delay(1)
		failSafeTime := (A_TickCount - failSafe) // 1000
    }
	
	FindImageAndClick(203, 272, 237, 300, , "Profile", 210, 140, 200) ; Open profile/stats page and wait
	
    ; Swipe until you get to trophy
	failSafe := A_TickCount
	failSafeTime := 0
    Loop {
        adbSwipe("266 770 266 355 300")
		if(FindOrLoseImage(13, 110, 31, 129, , "trophy", 0, failSafeTime)) 
			break
		failSafeTime := (A_TickCount - failSafe) // 1000
			
    }

	FindImageAndClick(122, 375, 161, 390, , "trophyPage", 50, 107, 200) ; Open pack trophy page
	
    ; Take screenshot and prepare for OCR
    Sleep, 100
	
	tempDir := A_ScriptDir . "\temp"
    if !FileExist(tempDir)
        FileCreateDir, %tempDir%
		
	fullScreenshotFile := tempDir . "\" .  winTitle . "_AccountPacks.png"
	adbTakeScreenshot(fullScreenshotFile)
    
	Sleep, 100
    
    packValue := 0
	trophyOCR := ""
    
	;214, 438, 111x30
	;214, 434, 111x38
	;214, 441, 111x24
	ocrSuccess := 0 
    if(RefinedOCRText(fullScreenshotFile, 214, 438, 111, 30, "0123456789,/", "^\d{1,3}(,\d{3})?\/\d{1,3}(,\d{3})?$", trophyOCR)) {
		;MsgBox, %trophyOCR%
		ocrParts := StrSplit(trophyOCR, "/")
		accountOpenPacks := ocrParts[1]
		;MsgBox, %accountOpenPacks%
		ocrSuccess := 1
		
		UpdateAccount()
	}

	if (FileExist(fullScreenshotFile))
		FileDelete, %fullScreenshotFile%
	
	FindImageAndClick(230, 120, 260, 150, , "UserProfile", 140, 496, 200) ; go back to hamburger menu
	
    Loop {
        adbClick(34,65)
			Delay(1)
        adbClick(34,65)
			Delay(1)
        adbClick(34,65)
			Delay(1)
        if(FindOrLoseImage(233, 400, 264, 428, , "Points", 0, failSafeTime)) {
            break
        } else {
			adbClick_wbb(141, 480)
			Delay(1)
		}
		failSafeTime := (A_TickCount - failSafe) // 1000
    }
}

; Attempts to extract and validate text from a specified region of a screenshot using OCR.
RefinedOCRText(screenshotFile, x, y, w, h, allowedChars, validPattern, ByRef output) {
    success := False
    ; Pack count gets bigger blowup
    if(output = "trophyOCR"){
        blowUp := [500, 1000, 2000, 100, 200, 250, 300, 350, 400, 450, 550, 600, 700, 800, 900]
    } else {
        blowUp := [200, 500, 1000, 2000, 100, 200, 250, 300, 400, 450, 550, 600, 700, 800, 900]
    }
    Loop, % blowUp.Length() {
        ; Get the formatted pBitmap
        pBitmap := CropAndFormatForOcr(screenshotFile, x, y, w, h, blowUp[A_Index])
        ; Run OCR
        output := GetTextFromBitmap(pBitmap, allowedChars)
        ; Validate result
        if (RegExMatch(output, validPattern)) {
            success := True
            break
        }
    }
    return success
}

; Crops an image, scales it up, converts it to grayscale, and enhances contrast to improve OCR accuracy.
CropAndFormatForOcr(inputFile, x := 0, y := 0, width := 200, height := 200, scaleUpPercent := 200) {
    ; Get bitmap from file
    pBitmapOrignal := Gdip_CreateBitmapFromFile(inputFile)
    ; Crop to region, Scale up the image, Convert to greyscale, Increase contrast
    pBitmapFormatted := Gdip_CropResizeGreyscaleContrast(pBitmapOrignal, x, y, width, height, scaleUpPercent, 75)
    
	filePath := A_ScriptDir . "\temp\" .  winTitle . "_AccountPacks_crop.png"
    Gdip_SaveBitmapToFile(pBitmap, filePath)
	; Cleanup references
    Gdip_DisposeImage(pBitmapOrignal)
    return pBitmapFormatted
}

; Extracts text from a bitmap using OCR. Converts the bitmap to a format usable by Windows OCR, performs OCR, and optionally removes characters not in the allowed character list.
GetTextFromBitmap(pBitmap, charAllowList := "") {
    global ocrLanguage
    ocrText := ""
    ; OCR the bitmap directly
    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
    pIRandomAccessStream := HBitmapToRandomAccessStream(hBitmap)
    ocrText := ocr(pIRandomAccessStream, ocrLanguage)
    ; Cleanup references
    DeleteObject(hBitmapFriendCode)
    ; Remove disallowed characters
    if (charAllowList != "") {
        allowedPattern := "[^" RegExEscape(charAllowList) "]"
        ocrText := RegExReplace(ocrText, allowedPattern)
    }

    return Trim(ocrText, " `t`r`n")
}

; Escapes special characters in a string for use in a regular expression. 
RegExEscape(str) {
    return RegExReplace(str, "([-[\]{}()*+?.,\^$|#\s])", "\$1")
}

; Function to URL-encode data AHK 1.1 compatible (Stolen from Ron KSBM)
UriEncode(str) {
    static hex := "0123456789ABCDEF"
    newStr := ""
    Loop, Parse, str
    {
        char := A_LoopField
        if (char ~= "[0-9a-zA-Z]")
            newStr .= char
        else
        {
            ascVal := Ord(char)
            newStr .= Format("%{:02X}", ascVal)
        }
    }
    return newStr
}
