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
    currentTopic : string;



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


procedure showNotes(commandWords: array of string);
begin
    printNoteList('All Notes', notes.topicNotes[currentTopic]);
end;


procedure showTopics(commandString: TCommandString);
var
    counter : integer;
    topic : string;
begin
    writeln('Topics: ');
    for counter := 0 to notes.topics.count - 1 do
    begin
        topic := notes.topics[counter];
        if topic = '' then
            topic := '<default>';
        writeln(' - ', topic);
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

procedure setCurrentTopic(commandString: TCommandString);
begin
    currentTopic := commandString.getRemaining;
end;


procedure processCommand(commandString: TCommandString);
var
    words : array of string;
    command : string;
begin
    command := commandString.popWord;

    case command of
        'q', 'quit': keepGoing := false;
        'w', 'write': notesFile.save(notes);
        'p', 'print': showNotes(words);
        's', 'search': searchNotes(commandString);
        't', 'topic': setCurrentTopic(commandString);
        'topics': showTopics(commandString);
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
        write(currentTopic, '> ');
        readln(line);

        if line[1] = ':' then
        begin
            commandString.setCommandString(line);
            processCommand(commandString);
        end
        else
        begin
            notes.addNote(currentTopic, line);
            line := '';
        end;
    end;

    notesFile.save(notes);

    
end.
