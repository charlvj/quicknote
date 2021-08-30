program quicknote;
{$MODE objfpc}{$H+}

uses
    crt, classes, sysutils, strutils,
    notesmodel, commands;


var
    notes : TNotes;
    notesFile : TNotesFile;
    commandString : TCommandString;
    keepGoing : boolean;
    line : string;



procedure showNotes(commandWords: array of string);
var
    counter : integer;
    note : PNote;
begin
    writeln('notes: ');
    for counter := 0 to notes.count - 1 do
    begin
        note := notes[counter];
        writeln(FormatDateTime('YYYY-MM-DD',note^.date), ' - ', note^.text);
    end;
end;

procedure printNoteList(header: string; noteList : TFPList);
var
    counter : integer;
    note : PNote;
begin
    writeln(header, ': ');
    for counter := 0 to noteList.count - 1 do
    begin
        note := noteList[counter];
        writeln(FormatDateTime('YYYY-MM-DD',note^.date), ' - ', note^.text);
    end;
end;


procedure searchNotes(commandString: TCommandString);
var 
    searchString : string;
    counter : integer;
    note : PNote;
    foundNotes : TFPList;
begin
    searchString := commandString.getRemaining;
    foundNotes := TFPList.create;

    for counter := 0 to notes.count - 1 do
    begin
        note := notes[counter];
        if findPart(searchString, note^.text) > 0 then
        begin
            foundNotes.add(note);
        end;
     end;

    printNoteList('Search Result', foundNotes);
    freeAndNil(foundNotes);
end;


procedure processCommand(commandString: TCommandString);
var
    words : array of string;
    command : string;
begin
    // if commandString[1] = ':' then
    //     commandString := midStr(commandString, 2, length(commandString) - 1);
    
    // words := splitString(commandString, ' ');
    // command := words[0];

    command := commandString.popWord;

    case command of
        'q', 'quit': keepGoing := false;
        'w', 'write': notesFile.save(notes);
        'p', 'print': showNotes(words);
        's', 'search': searchNotes(commandString);
    end;
end;



begin
    notes := TNotes.create;
    notesFile := TNotesFile.create;
    commandString := TCommandString.create;
    keepGoing := true;

    notesFile.load(notes);

    while keepGoing do
    begin
        write('> ');
        readln(line);

        if line[1] = ':' then
        begin
            commandString.setCommandString(line);
            processCommand(commandString);
        end
        else
        begin
            notes.addNote(line);
            line := '';
        end;
    end;

    notesFile.save(notes);

    
end.
