-- ******************************************************************
-- *
-- * QUEST PROPRIETARY INFORMATION
-- *
-- * This software is confidential.  Quest Inc., or one of its subsidiaries, has
-- * supplied this software to you under the terms of a license agreement,
-- * nondisclosure agreement or both.  You may not copy, disclose, or use this 
-- * software except in accordance with those terms.
-- *
-- * Copyright 2023 Quest Inc.  
-- * ALL RIGHTS RESERVED.
-- *
-- * QUEST INC. MAKES NO REPRESENTATIONS OR WARRANTIES
-- * ABOUT THE SUITABILITY OF THE SOFTWARE, EITHER EXPRESS
-- * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
-- * WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
-- * PARTICULAR PURPOSE, OR NON-INFRINGEMENT. QUEST SHALL
-- * NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE
-- * AS A RESULT OF USING, MODIFYING OR DISTRIBUTING
-- * THIS SOFTWARE OR ITS DERIVATIVES.
-- *
-- ******************************************************************


--  ******************************************************************
--  **       Stat™ 
--  ** ***************************************************************
--  ** *****                                                     *****
--  ** ***** PLEASE READ ALL INSTRUCTIONS IN FULL BEFORE RUNNING *****
--  ** *****                                                     *****
--  ** This script is subject to change without notice, and Quest Inc.
--  ** does not warrant that the material contained in the script is error-free. 
--  ** ***************************************************************
--  **
--  **  Name:        STAT-5976-ORA.sql (Support EBS_SYSTEM schema in SCA ,ORA Agent and Winclient)
--  **
--  **  Description: Support EBS_SYSTEM schema in SCA ,ORA Agent and Winclient 
--  **  Creator:     Prabal Awasthi
--  **	
--  **  Instructions:
--  **  - Database must be at Stat v6.3.0 before running this script
--  **  - Please read the release notes before executing the script.  
--  **
--  **    IMPORTANT
--  **  - Create a copy that is a FULL BACK UP of your existing database before running this script. 
--  **
--  **	- Modify the script as explained below in "Required Modifications"
--  **  - Run the modified script using Sql*Plus or Toad for Oracle (Do not run this or any Stat script with a third-party tool)
--  **
--  **  Required Modifications:
--  **	  This script contains variables that must be updated before executing.
--  **    Please find and replace with proper values: (You must find and replace the entire variable including the [ ])
--  ** 
--  **	1 - [DATABASENAME] < Replace with the name of the database. For example StatDev1
--  **  2 - [PWD]          < Replace with the password of the STAT Oracle user. For example St24816at
--  **	3 - [SPOOLPT]      < Replace with the directory for the Session Logs for this script. For example C:
--  **
--  **
--  **  Script Summary:
--  **  
--  **  a. Add column SYSTEM_USERNAME for EBS_SYSTEM implementation in stat 6.3
--  **  

-- A-01) Connect to appropriate Stat database

CONNECT STAT/[PWD]@[DATABASENAME]

SET SERVEROUTPUT ON
SET ECHO OFF
SET DEFINE OFF
SET HEADING OFF
SET VERIFY OFF
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
SET LINESIZE 999
SPOOL [SPOOLPT]/STAT-5976-ORA.LOG


SET SERVEROUTPUT ON SIZE 1000000
DECLARE
   l_script     VARCHAR2 (500 CHAR)   := 'STAT-5976-ORA.sql Started';
   l_username   VARCHAR2 (30 CHAR);
   l_schemaname VARCHAR2 (30 CHAR);
   l_machine    VARCHAR2 (64 CHAR);
   l_osuser     VARCHAR2 (30 CHAR);
   l_module     VARCHAR2 (48 CHAR);
   l_version    system_tbl.stat_db_version%TYPE;
BEGIN
   SELECT stat_db_version
     INTO l_version
     FROM stat.system_tbl;

   SELECT username, schemaname, machine, osuser, module
     INTO l_username, l_schemaname, l_machine, l_osuser, l_module
     FROM v$session
      WHERE audsid = (SELECT SYS_CONTEXT ('USERENV', 'SESSIONID') FROM DUAL);
    
   INSERT INTO stat.stat_dbscript_tbl
               (script_name, stat_version, run_dt,
                run_db_userinfo
               )
        VALUES (l_script, l_version, SYSDATE,
                   'User: '
                || l_username
                || ' Schema: '
                || l_schemaname
                || ' Machine: '
                || l_machine
                || ' OSuser: '
                || l_osuser
                || ' Module: '
                || l_module
               );
   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (SUBSTR (SQLERRM, 1, 200));
      RAISE;
END;
/
PROMPT * Data - STAT_DBSCRIPT_TBL Start

COMMIT;

-- ********************************************
-- A-03) Verify current version of Stat (Must be Stat v6.3.0, else return error message)

DECLARE
  statVersion system_tbl.stat_db_version%TYPE := 'Unknown';
BEGIN
  SELECT stat_db_version
  INTO statVersion
  FROM system_tbl;

  IF statVersion < '6.3.0'
  THEN
    RAISE_APPLICATION_ERROR(-20000, 'Your Stat database is at version ' || statVersion || '.' ||
                                    ' This script can only be run on Stat 6.3.0'   ||
                                    ' Please see the Upgrade Notes for details on how to sequentially upgrade from older versions.');
  END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND
    THEN 
      RAISE_APPLICATION_ERROR(-20001,'Stat is not licensed. Please log in to Stat and populate ' ||
                                      'license information before applying any upgrades.');
END;
/
PROMPT * Stat database version check
SELECT stat_db_version FROM system_tbl;

-- Add column SYSTEM_USERNAME for EBS_SYSTEM implementation in stat 6.3

DECLARE
    AlterDone NUMBER;
BEGIN
   SELECT COUNT(*) INTO AlterDone FROM USER_TAB_COLUMNS WHERE TABLE_NAME='STAT_PSDB_CONFIG' AND COLUMN_NAME in ('SYSTEM_USERNAME');
    IF AlterDone < 1 THEN
        execute immediate ('Alter table STAT_PSDB_CONFIG add SYSTEM_USERNAME VARCHAR2(50 BYTE) DEFAULT ''SYSTEM'' NOT NULL');
         DBMS_OUTPUT.put_line('*   STAT_PSDB_CONFIG - New column SYSTEM_USERNAME added');
    END IF;
END;
/



SET SERVEROUTPUT ON SIZE 1000000
DECLARE
   l_script     VARCHAR2 (500 CHAR)   := 'STAT-5976-ORA.sql Completed';
   l_username   VARCHAR2 (30 CHAR);
   l_schemaname VARCHAR2 (30 CHAR);
   l_machine    VARCHAR2 (64 CHAR);
   l_osuser     VARCHAR2 (30 CHAR);
   l_module     VARCHAR2 (48 CHAR);
   l_version    system_tbl.stat_db_version%TYPE;
BEGIN
   SELECT stat_db_version
     INTO l_version
     FROM stat.system_tbl;

   SELECT username, schemaname, machine, osuser, module
     INTO l_username, l_schemaname, l_machine, l_osuser, l_module
     FROM v$session
      WHERE audsid = (SELECT SYS_CONTEXT ('USERENV', 'SESSIONID') FROM DUAL);
    

   INSERT INTO stat.stat_dbscript_tbl
               (script_name, stat_version, run_dt,
                run_db_userinfo
               )
        VALUES (l_script, l_version, SYSDATE,
                   'User: '
                || l_username
                || ' Schema: '
                || l_schemaname
                || ' Machine: '
                || l_machine
                || ' OSuser: '
                || l_osuser
                || ' Module: '
                || l_module
               );
   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (SUBSTR (SQLERRM, 1, 200));
      RAISE;
END;
/
PROMPT * Data - STAT_DBSCRIPT_TBL Complete
COMMIT;
PROMPT ***
 SELECT '* End of STAT-5976-ORA-OracleServer for '||COMPANY_NAME FROM STAT.SYSTEM_TBL;
PROMPT *** ****************

SET SERVEROUTPUT OFF
SPOOL OFF