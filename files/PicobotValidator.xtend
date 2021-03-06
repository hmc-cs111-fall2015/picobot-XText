package edu.hmc.cs.picobot.validation

import edu.hmc.cs.picobot.picobot.BlockedEast
import edu.hmc.cs.picobot.picobot.BlockedNorth
import edu.hmc.cs.picobot.picobot.BlockedOrFree
import edu.hmc.cs.picobot.picobot.BlockedWest
import edu.hmc.cs.picobot.picobot.Declaration
import edu.hmc.cs.picobot.picobot.MoveEast
import edu.hmc.cs.picobot.picobot.MoveNorth
import edu.hmc.cs.picobot.picobot.MoveSouth
import edu.hmc.cs.picobot.picobot.MoveWest
import edu.hmc.cs.picobot.picobot.PicoState
import edu.hmc.cs.picobot.picobot.PicobotPackage
import edu.hmc.cs.picobot.picobot.Program
import edu.hmc.cs.picobot.picobot.Rule
import java.util.HashMap
import java.util.HashSet
import java.util.Set
import org.eclipse.xtext.validation.Check

/**
 * This class contains custom validation rules. 
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class PicobotValidator extends AbstractPicobotValidator {

    def protected void raiseMoveWarning(String direction, Boolean definite) {
        var possiblyString = "";
        if (!definite) {
            possiblyString = "possibly";
        }
        var warningString = String.format("Moving %s when %s is%s blocked", direction, direction, possiblyString);
        warning(warningString, PicobotPackage.Literals.RULE__MOVE);
    }

    @Check
    def void checkMovingToBlocked(Rule rule) {
        var pattern = rule.getPattern();
        var move = rule.getMove();

        if (move instanceof MoveNorth) {
            var patternDirection = pattern.getNorth();
            if (patternDirection instanceof BlockedNorth) {
                raiseMoveWarning("north", true);
            } else if (patternDirection instanceof BlockedOrFree) {
                raiseMoveWarning("north", false);
            }
        } else if (move instanceof MoveEast) {
            var patternDirection = pattern.getEast();
            if (patternDirection instanceof BlockedEast) {
                raiseMoveWarning("east", true);
            } else if (patternDirection instanceof BlockedOrFree) {
                raiseMoveWarning("east", false);
            }
        } else if (move instanceof MoveWest) {
            var patternDirection = pattern.getWest();
            if (patternDirection instanceof BlockedWest) {
                raiseMoveWarning("west", true);
            } else if (patternDirection instanceof BlockedOrFree) {
                raiseMoveWarning("west", false);
            }
        } else if (move instanceof MoveSouth) {
            var patternDirection = pattern.getSouth();
            if (patternDirection instanceof BlockedWest) {
                raiseMoveWarning("south", true);
            } else if (patternDirection instanceof BlockedOrFree) {
                raiseMoveWarning("south", false);
            }
        }
    }

    @Check
    def void checkReachableStates(Program p) {
        var allStates = new HashSet<PicoState>();
        var usedStates = new HashSet<PicoState>();
        var targets = new HashMap<PicoState, Set<PicoState>>();

        // find all states and their immediate targets
        for (Declaration d : p.getDeclarations()) {
            if (d instanceof PicoState) {
                allStates.add(d);
            }

            if (d instanceof Rule) {
                var source = d.getSource();
                var target = d.getTarget();

                usedStates.add(source);
                usedStates.add(target);

                if (targets.containsKey(source)) {
                    targets.get(source).add(target);
                } else {
                    var targetSet = new HashSet<PicoState>();
                    targetSet.add(target);
                    targets.put(source, targetSet);
                }
            }
        }

        // compute transitive reachability
        var reachableStates = new HashSet<PicoState>();

        var startState = p.getStart().getState();
        if (targets.containsKey(startState)) {
            reachableStates.add(startState);
            var oldSize = 0;
            do {
                oldSize = reachableStates.size();
                var boundary = new HashSet<PicoState>();
                for (PicoState state : reachableStates)
                    if (targets.containsKey(state)) {
                        boundary.addAll(targets.get(state));
                    }
                reachableStates.addAll(boundary);
            } while (oldSize != reachableStates.size());
        } else
            error("Start state " + p.getStart().getState().getName() + " is never used", p.getStart(),
                PicobotPackage.Literals.START_STATE_DECLARATION__STATE, 1);

        // register warnings
        for (PicoState s : allStates) {
            if (!usedStates.contains(s)) {
                warning("Unused state: " + s.getName(), s, PicobotPackage.Literals.PICO_STATE__NAME, 2);
            } else if (!reachableStates.contains(s)) {
                warning("Unreachable state: " + s.getName(), s, PicobotPackage.Literals.PICO_STATE__NAME, 3);
            }

        }
    }
}

