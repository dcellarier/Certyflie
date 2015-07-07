with System; use System;
with Types; use Types;
with Interfaces.C.Extensions; use Interfaces.C.Extensions;
with FreeRTOS_Pack; use FreeRTOS_Pack;

package Worker_Pack
with SPARK_Mode
is
   --  Types

   --  Worker functions currently supported.
   type Action is (Log_Run, Neo_Pixel_Ring, None);

   --  Element type of the worker queue. 'Action' refers to a worker function
   --  and 'Arg' to its argument.
   type Worker_Work is record
      Func : Action;
      Arg  : Pvoid;
   end record;

   --  Global variables and constants

   WORKER_QUEUE_LENGTH : constant T_Uint32 := 5;

   Worker_Queue : Pvoid := System.Null_Address;

   --  Procedures and functions

   --  Initialize the worker queue.
   procedure Worker_Init;
   pragma Export (C, Worker_Init, "ada_workerInit");

   --  Test if the worker queue is valid.
   function Worker_Test return bool;
   pragma Export (C, Worker_Test, "ada_workerTest");

   --  Main loop calling all teh worker functions in the worker queue.
   procedure Worker_Loop;
   pragma Export (C, Worker_Loop, "ada_workerLoop");

   --  Add a worker function to the worker queue.
   function Worker_Schedule
     (Func_ID : Integer;
      Arg     : Pvoid) return Integer;
   pragma Export (C, Worker_Schedule, "ada_workerSchedule");

   --  Worker function to send log data.
   procedure Log_Run_Worker (Arg : Pvoid);

   --  Worker function to begin a LED sequence of Neo Pixel Ring.
   procedure Neo_Pixel_Ring_Worker (Arg : Pvoid);

end Worker_Pack;
