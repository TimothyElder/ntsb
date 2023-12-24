-- .import aircraft.csv aircraft
-- .import Country.csv country
-- .import ct_laids.csv ct_laids
-- .import ct_seqevt.csv ct_seqevt
-- .import dt_aircraft.csv dt_aircraft
-- .import dt_events.csv dt_events
-- .import dt_Flight_Crew.csv dt_Flight_Crew
-- .import engines.csv engines
-- .import events.csv events
-- .import Findings.csv findings
-- .import Flight_Crew.csv flight_crew
-- .import injury.csv injury
-- .import narratives.csv narratives
-- .import Occurrences.csv occurrences
-- .import seq_of_events.csv seq_of_events
-- .import states.csv states
-- .import eADMSPUB_DataDictionary.csv dictionary

PRAGMA table_info(events);

SELECT * FROM events WHERE ev_highest_injury = 'FATL';

SELECT * FROM dictionary WHERE damage

.schema dictionary

SELECT DISTINCT damage FROM aircraft;

SELECT * FROM dictionary WHERE  = 'SUBS';

SELECT *
FROM dictionary
WHERE 'table' = 'aircraft' OR column = 'damage';