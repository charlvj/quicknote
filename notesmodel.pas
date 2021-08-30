unit notesmodel;
{$MODE objfpc}{$H+}
interface
    
uses
    SysUtils, Classes, strutils, fgl;
    

type
    TNote = record
        date : TDateTime;
        topic : string;
        text : string;
    end;
    PNote = ^TNote;

    TNotes = class
    private
        _notes : TFPList;
        _topics : TStringList;
    public
        constructor Create();
        destructor Destroy; override;

        function addNote(text: string):PNote; overload;
        function addNote(date: TDateTime; text: string) : PNote; overload;
        function addNote(topic: string; text: string) : PNote; overload;
        function addNote(topic: string; date: TDateTime; text: string) : PNote; overload;

        function getCount : integer;
        function getNote(idx : integer) : PNote;

        function getTopic(idx : integer) : string;
        function getTopicNotes(topic: string) : TFPList;
        function hasTopic(topic: string) : boolean;

        property notes[idx : integer] : PNote read getNote; default;
        property topicNotes[topic : string] : TFPList read getTopicNotes;
        
    published
        property count : integer read getCount;
        property allNotes : TFPList read _notes;
        property topics : TStringList read _topics;
    end;


    TNotesFile = class
    private
        _directory : string;
        _filename : string;

        function getFilename : string;
    public
        constructor Create(); overload;
        constructor Create(directory, filename : string); overload;
        destructor Destroy(); override;

        procedure save(notes : TNotes);
        procedure load(notes : TNotes);
    end;

implementation
    
constructor TNotes.Create();
begin
    _notes := TFPList.create();
    _topics := TStringList.create();
    _topics.sorted := true;
end;

destructor TNotes.Destroy;
begin
    freeAndNil(_notes);
    freeAndNil(_topics);
end;


function TNotes.addNote(text: string):PNote;
begin
    result := addNote(date, text);
end;


function TNotes.addNote(date: TDateTime; text: string) : PNote;
begin
    result := addNote('', date, text);
end;


function TNotes.addNote(topic, text: string):PNote;
begin
    result := addNote(topic, date, text);
end;


function TNotes.addNote(topic: string; date: TDateTime; text: string) : PNote;
var
    note : PNote;
begin
    note := new(PNote);
    note^.topic := topic;
    note^.date := date;
    note^.text := text;
    _notes.add(note);

    if not hasTopic(topic) then
        _topics.add(topic);

    result := note;
end;

function TNotes.getCount() : integer;
begin
    result := _notes.count;
end;


function TNotes.getNote(idx : integer) : PNote;
begin
    result := _notes[idx];
end;


function TNotes.hasTopic(topic: string) : boolean;
var
    counter : integer;
begin
    topic := lowercase(topic);
    result := false;
    for counter := 0 to _topics.count - 1 do
    begin
        if topic = lowercase(_topics[counter]) then
        begin
            result := true;
            break;
        end;
    end;
end;


function TNotes.getTopic(idx: integer) : string;
begin
    result := _topics[idx];
end;

function TNotes.getTopicNotes(topic: string) : TFPList;
var
    counter : integer;
    note : PNote;
begin
    result := TFPList.create();
    for counter := 0 to _notes.count - 1 do
    begin
        note := _notes[counter];
        if note^.topic = topic then
            result.add(note);
    end;
end;








constructor TNotesFile.Create();
begin
    _directory := getUserDir + '.quicknotes/';
    _filename := 'notes.quicknotes';
end;


constructor TNotesFile.Create(directory, filename : string);
begin
    _directory := directory;
    _filename := filename;
end;

destructor TNotesFile.Destroy();
begin
    
end;


function TNotesFile.getFilename : string;
begin
    result := _directory + _filename;
end;

procedure TNotesFile.save(notes : TNotes);
var 
    counter, topicCounter : integer;
    note : PNote;
    topicNotes : TFPList;
    topic : string;
    outputFile : text;
begin
    if not directoryExists(_directory) then
        createDir(_directory);

    assign(outputFile, getFilename());
    rewrite(outputFile);

    for topicCounter := 0 to notes.topics.count - 1 do
    begin
        topic := notes.topics[topicCounter];
        topicNotes := notes.topicNotes[topic];

        if topic <> '' then
            writeln(outputFile, '[', topic, ']');

        for counter := 0 to topicNotes.count - 1 do
        begin
            note := topicNotes[counter];
            writeln(outputFile, 
                    dateToStr(note^.date),
                    #9,
                    note^.text);
        end;
    end;
    close(outputFile);
end;

procedure TNotesFile.load(notes : TNotes);
var
    inputFile : text;
    line : string;
    tabPos : integer;
    topic, dateStr, text : string;
begin
    if fileExists(getFilename()) then
    begin
        assign(inputFile, getFilename());
        reset(inputFile);

        while not eof(inputFile) do
        begin
            readln(inputFile, line);

            if line = '' then
                continue;

            if line[1] = '[' then
            begin
                // reading a topic
                topic := trimSet(line, ['[',']']);
            end
            else
            begin
                tabPos := npos(#9, line, 1);
                dateStr := midStr(line, 1, tabPos);
                text := midStr(line, tabPos + 1, length(line) - tabPos);

                notes.addNote(topic, strToDate(dateStr), text);
            end;
        end;

        close(inputFile);
    end;
end;

begin
    
end.