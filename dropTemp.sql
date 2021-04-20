
;IF object_id('TEMPDB..##toInsert') IS not null BEGIN
    drop table ##toInsert
    end
IF object_id('TEMPDB..##kalla') IS not null BEGIN
drop table ##kalla
end
IF object_id('TEMPDB..##fordig') IS not null BEGIN
drop table ##fordig
end
;
