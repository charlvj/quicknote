program quicknote;
{$MODE objfpc}{$H+}

uses
    crt, classes, sysutils, strutils,
    notesmodel;


var
    notes : TNotes;
    notesFile : TNotesFile;
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


procedure processCommand(commandString: string);
var
    words : array of string;
    command : string;
begin
    if commandString[1] = ':' then
        commandString := midStr(commandString, 2, length(commandString) - 1);
    
    words := splitString(commandString, ' ');
    command := words[0];

    case command of
        'q', 'quit': keepGoing := false;
        'w', 'write': notesFile.save(notes);
        's', 'show': showNotes(words);
    end;
end;



begin
    notes := TNotes.create;
    notesFile := TNotesFile.create;
    keepGoing := true;

    notesFile.load(notes);

    while keepGoing do
    begin
        write('> ');
        readln(line);

        if line[1] = ':' then
        begin
            processCommand(line);
        end
        else
        begin
            notes.addNote(line);
            line := '';
        end;
    end;

    notesFile.save(notes);

    
end.
