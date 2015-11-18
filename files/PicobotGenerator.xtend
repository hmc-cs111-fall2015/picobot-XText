grammar edu.cs.hmc.picobot.Picobot with org.eclipse.xtext.common.Terminals

generate picobot "http://www.cs.edu/hmc/picobot/Picobot"

Program :
  declarations+=Declaration*
  start=StartStateDeclaration
;

Declaration :
  PicoState | Rule
;

PicoState :
  'state:' name=ID ';'
;

Rule :
  'rule:' source=[PicoState] '[' pattern=Pattern ']' '->' 
          move=MoveDirection target=[PicoState] ';' 
;

Pattern : 
  north=NorthPatternDirection east=EastPatternDirection 
  west=WestPatternDirection south=SouthPatternDirection
;

NorthPatternDirection :
    'N' {BlockedNorth}
 |  AltPatternDirection
;

EastPatternDirection:
   'E' {BlockedEast}
 |  AltPatternDirection
;

WestPatternDirection:
    'W' {BlockedWest}
 |  AltPatternDirection
;

SouthPatternDirection:
    'S' {BlockedSouth}
 |  AltPatternDirection
;
    
AltPatternDirection: 
    'x' {Free}
 |  '*' {BlockedOrFree}
;

MoveDirection:
    'N' {MoveNorth}
  | 'E' {MoveEast}
  | 'W' {MoveWest}
  | 'S' {MoveSouth}  
  | 'X' {Stay}
;

StartStateDeclaration:
  'startwith:' state=[PicoState] ';'
;
