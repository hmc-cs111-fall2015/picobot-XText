package edu.hmc.cs.picobot.generator

import edu.hmc.cs.picobot.picobot.AltPatternDirection
import edu.hmc.cs.picobot.picobot.BlockedEast
import edu.hmc.cs.picobot.picobot.BlockedNorth
import edu.hmc.cs.picobot.picobot.BlockedSouth
import edu.hmc.cs.picobot.picobot.BlockedWest
import edu.hmc.cs.picobot.picobot.EastPatternDirection
import edu.hmc.cs.picobot.picobot.Free
import edu.hmc.cs.picobot.picobot.MoveDirection
import edu.hmc.cs.picobot.picobot.MoveEast
import edu.hmc.cs.picobot.picobot.MoveNorth
import edu.hmc.cs.picobot.picobot.MoveSouth
import edu.hmc.cs.picobot.picobot.MoveWest
import edu.hmc.cs.picobot.picobot.NorthPatternDirection
import edu.hmc.cs.picobot.picobot.Pattern
import edu.hmc.cs.picobot.picobot.Program
import edu.hmc.cs.picobot.picobot.Rule
import edu.hmc.cs.picobot.picobot.SouthPatternDirection
import edu.hmc.cs.picobot.picobot.StartStateDeclaration
import edu.hmc.cs.picobot.picobot.WestPatternDirection
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class PicobotGenerator implements IGenerator {

  override void doGenerate(Resource resource, IFileSystemAccess fsa) {
    System.out.println(resource.allContents);
    for (p : resource.allContents.toIterable.filter(Program)) {
      fsa.generateFile(resource.fileName + ".dot", p.toDot)
    }
  }

  def fileName(Resource resource) {
    var name = resource.URI.lastSegment
    return name.substring(0, name.indexOf('.'))
  }

  def toDot(Program p) '''
digraph picobot {
   rankdir=LR
   «p.start.toDot»
   «FOR d : p.declarations»
     «IF d instanceof Rule»
       «(d as Rule).toDot»
     «ENDIF»
   «ENDFOR»
}
'''

  def toDot(StartStateDeclaration s) '''«s.state.name»[color=darkgreen]'''

  def toDot(Rule r) '''
    "«r.source.name»" -> "«r.target.name»" [label="[«r.pattern.toDot»]{«r.move.toDot»}"]
  '''

  def toDot(Pattern p) {
    '''«p.north.toDot»«p.east.toDot»«p.west.toDot»«p.south.toDot»'''
  }

  def toDot(NorthPatternDirection n) {
    if (n instanceof BlockedNorth) '''N''' else
      (
      (n as AltPatternDirection).toDot)
  }

  def toDot(EastPatternDirection e) {
    if (e instanceof BlockedEast) '''E''' else
      (
      (e as AltPatternDirection).toDot)
  }

  def toDot(WestPatternDirection w) {
    if (w instanceof BlockedWest) '''W''' else
      (
      (w as AltPatternDirection).toDot)
  }

  def toDot(SouthPatternDirection s) {
    if (s instanceof BlockedSouth) '''S''' else
      (
      (s as AltPatternDirection).toDot)
  }

  def toDot(AltPatternDirection a) {
    if (a instanceof Free) '''x''' else '''*'''
  }

  def toDot(MoveDirection m) {
    if (m instanceof MoveNorth) '''N''' else if (m instanceof MoveEast) '''E''' else if (m instanceof MoveWest) '''W''' else if (m instanceof MoveSouth) '''S''' else '''X'''
  }
}
