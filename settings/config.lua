Config = Config or {} -- Do not touch this!!!
Bridge = Bridge or {} -- Do not touch this!!!

Config.StampClocks = {
    {
        id = 4, -- This is the FractionID
        job = 'police',
        coords = vector3(440.4121, -975.7260, 30.6896),
        blip = {
            label = 'Stamp Clock',
            sprite = 430,
            color = 38
        }
    },

}

Config.Notify = function(title, description, type)
    lib.notify({
        title = title,
        description = description,
        type = type
    })
end

Config.Language = 'en'
Config.Translation = {

    ['en'] = {
        stampclock = {
            interaction = 'Open the stamp clock',
            notifySuccessStamp = 'You have successfully stamped',
            notifyFailedStamp = 'You have failed to stamp',
            notifyCooldownStamp = 'You have to wait to stamp again',
            notifyStampTitle = {
                ['IN'] = 'Stamp In',
                ['OUT'] = 'Stamp Out',
            },
            contextMenuTitle = 'Stamp Clock',
            contextMenuLastStampTitle = 'Status: %s',
            contextMenuLastStampTypes = {
                ['IN'] = 'Stamp In',
                ['OUT'] = 'Stamp Out',
            },
            contextMenuPreviousStampsTitle = 'Previous Stamps',
            contextMenuPreviousStampsDescription = 'See your previous stamps',
            contextMenuStampInTitle = 'Stamp In',
            contextMenuStampInDescription = 'Stamp in and go on duty',
            contextMenuStampOutTitle = 'Stamp Out',
            contextMenuStampOutDescription = 'Clock out and leave duty',
            contextMenuPreviousMenuTitle = 'Previous Stamps',
            contextMenuPreviousMenuEmpty = 'No previous stamps found',
        },
    },

    ['de'] = {
        stampclock = {
            interaction = 'Stempeluhr öffnen',
            notifySuccessStamp = 'Du hast erfolgreich gestempelt',
            notifyFailedStamp = 'Das Stempeln ist fehlgeschlagen',
            notifyCooldownStamp = 'Du musst warten, um erneut zu stempeln',
            notifyStampTitle = {
                ['IN'] = 'Einstempeln',
                ['OUT'] = 'Austempeln',
            },
            contextMenuTitle = 'Stempeluhr',
            contextMenuLastStampTitle = 'Status: %s',
            contextMenuLastStampTypes = {
                ['IN'] = 'Eingestempelt',
                ['OUT'] = 'Ausgestempelt',
            },
            contextMenuPreviousStampsTitle = 'Vorherige Zeiterfassungen',
            contextMenuPreviousStampsDescription = 'Zeige deine vorherigen Zeiterfassungen',
            contextMenuStampInTitle = 'Einstempeln',
            contextMenuStampInDescription = 'Einstempeln und den Dienst antreten',
            contextMenuStampOutTitle = 'Ausstempeln',
            contextMenuStampOutDescription = 'Ausstempeln und den Dienst verlassen',
            contextMenuPreviousMenuTitle = 'Vorherige Zeiterfassung',
            contextMenuPreviousMenuEmpty = 'Keine vorherigen Zeiterfassungen gefunden',
        },
    }


}
