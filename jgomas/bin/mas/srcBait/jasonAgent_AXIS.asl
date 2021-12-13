debug(3).

// Name of the manager
manager("Manager").

// Team of troop.
team("AXIS").
// Type of troop.
type("CLASS_SOLDIER").

// Value of "closeness" to the Flag, when patrolling in defense
patrollingRadius(32).




{ include("jgomas.asl") }


// Plans


/*******************************
*
* Actions definitions
*
*******************************/

+!generate_safe_position
    <-  ?my_position(_, Y, _);
        .random(A); //select zone between up and down right entry
        if (A < 0.2){ //up
            .random(X);
            .random(Z);
            NewX = X * 10 + 20;
            NewZ = Z * 10 + 190;
        }
        else{ //down
            .random(X);
            .random(Z);
            NewX = X * 10 + 50;
            NewZ = Z * 20 + 225;
        }
        !safe_pos(NewX, Y, NewZ).

/////////////////////////////////
//  GET AGENT TO AIM
/////////////////////////////////
/**
 * Calculates if there is an enemy at sight.
 *
 * This plan scans the list <tt> m_FOVObjects</tt> (objects in the Field
 * Of View of the agent) looking for an enemy. If an enemy agent is found, a
 * value of aimed("true") is returned. Note that there is no criterion (proximity, etc.) for the
 * enemy found. Otherwise, the return value is aimed("false")
 *
 * <em> It's very useful to overload this plan. </em>
 * 
 */
+!get_agent_to_aim
    <-  ?debug(Mode); if (Mode<=2) { .println("Looking for agents to aim."); }
    ?fovObjects(FOVObjects);
    .length(FOVObjects, Length);

    ?debug(Mode); if (Mode<=1) { .println("El numero de objetos es:", Length); }

    if (Length > 0) {
        +bucle(0);
        
        -+aimed("false");
        
        while (not no_shoot("true") & bucle(X) & (X < Length)) {
            
            //.println("En el bucle, y X vale:", X);
            
            .nth(X, FOVObjects, Object);
            // Object structure
            // [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
            .nth(2, Object, Type);
            
            ?debug(Mode); if (Mode<=2) { .println("Objeto Analizado: ", Object); }
            
            if (Type > 1000) {
                ?debug(Mode); if (Mode<=2) { .println("I found some object."); }
            } else {
                // Object may be an enemy
                .nth(1, Object, Team);
                ?my_formattedTeam(MyTeam);
                
                if (Team == 100) {  // Only if I'm AXIS
                    
                    ?debug(Mode); if (Mode<=2) { .println("Aiming an enemy. . .", MyTeam, " ", .number(MyTeam) , " ", Team, " ", .number(Team)); }
                    +aimed_agent(Object);
                    -+aimed("true");
                    
                }  else {
                    if (Team == 200) {
                        .nth(3, Object, Angle);
                        if (math.abs(Angle) < 0.1) {
                            +no_shoot("true");
                        } 
                    }
                }
                
            }
            
            -+bucle(X+1);
            
        }

        if (no_shoot("true")) {
            -aimed_agent(_);
            -+aimed("false");
            -no_shoot("true");
        }
        
        
    }

    -bucle(_).

        

/////////////////////////////////
//  LOOK RESPONSE
/////////////////////////////////
+look_response(FOVObjects)[source(M)]
    <-  //-waiting_look_response;
        .length(FOVObjects, Length);
        if (Length > 0) {
            ///?debug(Mode); if (Mode<=1) { .println("HAY ", Length, " OBJETOS A MI ALREDEDOR:\n", FOVObjects); }
        };    
        -look_response(_)[source(M)];
        -+fovObjects(FOVObjects);
        //.//;
        !look.
      
        
/////////////////////////////////
//  PERFORM ACTIONS
/////////////////////////////////
/**
 * Action to do when agent has an enemy at sight.
 *
 * This plan is called when agent has looked and has found an enemy,
 * calculating (in agreement to the enemy position) the new direction where
 * is aiming.
 *
 *  It's very useful to overload this plan.
 * 
 */

+!perform_aim_action
    <-  // Aimed agents have the following format:
        // [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
        ?aimed_agent(AimedAgent);
        ?debug(Mode); if (Mode<=1) { .println("AimedAgent ", AimedAgent); }
        .nth(1, AimedAgent, AimedAgentTeam);
        ?debug(Mode); if (Mode<=2) { .println("BAJO EL PUNTO DE MIRA TENGO A ALGUIEN DEL EQUIPO ", AimedAgentTeam); }
        ?my_formattedTeam(MyTeam);


        if (AimedAgentTeam == 100) {
        
            .nth(6, AimedAgent, NewDestination);
            ?debug(Mode); if (Mode<=1) { .println("NUEVO DESTINO MARCADO: ", NewDestination); }
            //update_destination(NewDestination);
        }
        .
    
/**
 * Action to do when the agent is looking at.
 *
 * This plan is called just after Look method has ended.
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!perform_look_action 
    <-  ?tasks(TaskList);
        ?current_task(task(_, TaskType, _, pos(TaskX, TaskY, TaskZ), _));
        if (TaskType == "TASK_GOTO_POSITION") { //Prevents bug of getting stuck in a wall recalculating its path
            ?prev_pos(X, Y, Z);
            if (TaskX == X & TaskY == Y & TaskZ == Z) {
                .delete(task(_, "TASK_GOTO_POSITION", _, pos(TaskX, TaskY, TaskZ), _), TaskList, NewTaskList);
                -+tasks(NewTaskList);
                !generate_safe_position;
                ?safe_pos(SafeX, SafeY, SafeZ);
                -safe_pos(SafeX, SafeY, SafeZ);
                .my_name(MyName);
                !add_task(task("TASK_GOTO_POSITION", MyName, pos(SafeX, SafeY, SafeZ), ""));
                ?task_priority("TASK_GOTO_POSITION", Priority);
                -+current_task(task(Priority, "TASK_GOTO_POSITION", MyName, pos(SafeX, SafeY, SafeZ), ""));
                .println("Added New Task! Going to Position: ", SafeX, ", ", SafeY, ", ", SafeZ);
            }
        }
        ?my_position(MyX, MyY, MyZ);
        -+prev_pos(MyX, MyY, MyZ);

        ?fovObjects(FOVObjects);
        for(.member(CurrentObject, FOVObjects)) {
            .nth(1, CurrentObject, ObjectTeam);
            .nth(6, CurrentObject, pos(ObjectX, ObjectY, ObjectZ));
            if (ObjectTeam == 100) {
                .my_team("backup_AXIS", MyTeam);
                .concat("enemy(", ObjectX, ", ", ObjectY, ", ", ObjectZ, ")", MsgContent);
                .send_msg_with_conversation_id(MyTeam, tell, MsgContent, "INT");
            }
        }
        .

/**
 * Action to do if this agent cannot shoot.
 *
 * This plan is called when the agent try to shoot, but has no ammo. The
 * agent will spit enemies out. :-)
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!perform_no_ammo_action .
/// <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR PERFORM_NO_AMMO_ACTION GOES HERE.") }.

/**
 * Action to do when an agent is being shot.
 *
 * This plan is called every time this agent receives a messager from
 * agent Manager informing it is being shot.
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!perform_injury_action .
///<- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR PERFORM_INJURY_ACTION GOES HERE.") }.


/////////////////////////////////
//  SETUP PRIORITIES
/////////////////////////////////
/**  You can change initial priorities if you want to change the behaviour of each agent  **/
+!setup_priorities
    <-  +task_priority("TASK_NONE",0);
        +task_priority("TASK_GIVE_MEDICPAKS", 2000);
        +task_priority("TASK_GIVE_AMMOPAKS", 0);
        +task_priority("TASK_GIVE_BACKUP", 0);
        +task_priority("TASK_GET_OBJECTIVE",1000);
        +task_priority("TASK_ATTACK", 1000);
        +task_priority("TASK_RUN_AWAY", 1500);
        +task_priority("TASK_GOTO_POSITION", 750);
        +task_priority("TASK_PATROLLING", 500);
        +task_priority("TASK_WALKING_PATH", 750);.   



/////////////////////////////////
//  UPDATE TARGETS
/////////////////////////////////
/**
 * Action to do when an agent is thinking about what to do.
 *
 * This plan is called at the beginning of the state "standing"
 * The user can add or eliminate targets adding or removing tasks or changing priorities
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!update_targets 
    <-  ?tasks(TaskList);
        if (.member(task(_, "TASK_PATROLLING", _, _, _), TaskList)) {
            .delete(task(_, "TASK_PATROLLING", _, _, _), TaskList, NewTaskList);
            -+tasks(NewTaskList);
            .println("Removed TASK_PATROLLING from my tasks.");
        }

        ?tasks(TaskListNew);
        .length(TaskListNew, TaskLength);
        if (TaskLength <= 0) {
            !generate_safe_position;
            ?safe_pos(SafeX, SafeY, SafeZ);
            -safe_pos(SafeX, SafeY, SafeZ);
            .my_name(MyName);
            !add_task(task("TASK_GOTO_POSITION", MyName, pos(SafeX, SafeY, SafeZ), ""));
            .println("Added New Task! Going to Position: ", SafeX, ", ", SafeY, ", ", SafeZ);
        } else { // This removes TASK_WALKING_PATH bug: infinite cycle of +1 Priority to TASK_WALKING_PATH
            ?current_task(task(Priority, TaskType, _, _, _));

            if (TaskType == "TASK_WALKING_PATH" & task_priority(TaskType, TaskPrio) & Priority > (TaskPrio + 1)) {
                .delete(task(_, "TASK_WALKING_PATH", _, _, _), TaskListNew, UnBuggedTaskList1);
                .delete(task(_, "TASK_GOTO_POSITION", _, _, _), UnBuggedTaskList1, UnBuggedTaskList2);
                -+tasks(UnBuggedTaskList2);
                !generate_safe_position;
                ?safe_pos(SafeX, SafeY, SafeZ);
                -safe_pos(SafeX, SafeY, SafeZ);
                .my_name(MyName);
                !add_task(task("TASK_GOTO_POSITION", MyName, pos(SafeX, SafeY, SafeZ), ""));
                -+current_task(task("TASK_GOTO_POSITION", MyName, pos(SafeX, SafeY, SafeZ)));
                .println("Added New Task! Going to Position: ", SafeX, ", ", SafeY, ", ", SafeZ);
            }
        }.
	
	
/////////////////////////////////
//  CHECK MEDIC ACTION (ONLY MEDICS)
/////////////////////////////////
/**
 * Action to do when a medic agent is thinking about what to do if other agent needs help.
 *
 * By default always go to help
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!checkMedicAction
<-  -+medicAction(on).
// go to help


/////////////////////////////////
//  CHECK FIELDOPS ACTION (ONLY FIELDOPS)
/////////////////////////////////
/**
 * Action to do when a fieldops agent is thinking about what to do if other agent needs help.
 *
 * By default always go to help
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!checkAmmoAction
<-  -+fieldopsAction(on).
//  go to help



/////////////////////////////////
//  PERFORM_TRESHOLD_ACTION
/////////////////////////////////
/**
 * Action to do when an agent has a problem with its ammo or health.
 *
 * By default always calls for help
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!performThresholdAction
       <-
       
       ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR PERFORM_TRESHOLD_ACTION GOES HERE.") }
       
       ?my_ammo_threshold(At);
       ?my_ammo(Ar);
       
       if (Ar <= At) { 
          ?my_position(X, Y, Z);
          
         .my_team("fieldops_AXIS", E1);
         //.println("Mi equipo intendencia: ", E1 );
         .concat("cfa(",X, ", ", Y, ", ", Z, ", ", Ar, ")", Content1);
         .send_msg_with_conversation_id(E1, tell, Content1, "CFA");
       
       
       }
       
       ?my_health_threshold(Ht);
       ?my_health(Hr);
       
       if (Hr <= Ht) {  
          ?my_position(X, Y, Z);
          
         .my_team("medic_AXIS", E2);
         //.println("Mi equipo medico: ", E2 );
         .concat("cfm(",X, ", ", Y, ", ", Z, ", ", Hr, ")", Content2);
         .send_msg_with_conversation_id(E2, tell, Content2, "CFM");

       }
       .
       
/////////////////////////////////
//  ANSWER_ACTION_CFM_OR_CFA
/////////////////////////////////

   
    
+cfm_agree[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfm_agree GOES HERE.")};
      -cfm_agree.  

+cfa_agree[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfa_agree GOES HERE.")};
      -cfa_agree.  

+cfm_refuse[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfm_refuse GOES HERE.")};
      -cfm_refuse.  

+cfa_refuse[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfa_refuse GOES HERE.")};
      -cfa_refuse.  

+enemy(X, Y, Z)[source(M)]
    <-  .my_name(MName);
        !add_task(task("TASK_GOTO_POSITION", MName, pos(X, Y, Z), ""));
        -+state(standing);
        -+prev_pos(X, Y, Z);
        -enemy(X, Y, Z)[source(M)].

/////////////////////////////////
//  Initialize variables
/////////////////////////////////

+!init 
    <-  .my_name(MyName);
        -+current_task(task(749, "DUMMY_TASK", MyName, pos(0, 0, 0), ""));
        ?my_position(X, Y, Z);
        +prev_pos(X, Y, Z). 

