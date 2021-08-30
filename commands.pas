unit commands;
{$MODE objfpc}{$H+}

interface

uses
    classes, strutils;

type
    TCommandString = class
    private
        _commandString : string;
        _nextWord : integer;

    public
        procedure setCommandString(str: string);
        function popWord : string;
        function getRemaining : string;
    end;

implementation

procedure TCommandString.setCommandString(str: string);
begin
    _commandString := str;
    _nextWord := 1;

    if _commandString[1] = ':' then
        _commandString := midStr(_commandString, 2, length(_commandString) - 1);
end;


function TCommandString.popWord : string;
begin
    result := extractSubstr(_commandString, _nextWord, [' ']);
end;


function TCommandString.getRemaining : string;
begin
    result := midStr(_commandString, _nextWord, length(_commandString) - _nextWord + 1);
end;


end.