select * from dates where SITE = 'Karanovo';

select LABNR, MATERIAL, SPECIES, SITE, PERIOD, CULTURE, LATITUDE, LONGITUDE, METHOD, CALAGE, CALSTD, REFERENCE 
from dates 
where SITE = 'Karanovo';

/*youngest dates of each site*/
select a.SITE, a.LABNR, a.CALAGE
from dates a
  left join dates b
    on a.SITE = b.SITE and a.CALAGE > b.CALAGE
where b.CALAGE is NULL;

/*oldest dates of each site*/
select a.SITE, a.LABNR, a.CALAGE
from dates a
  left join dates b
    on a.SITE = b.SITE and a.CALAGE < b.CALAGE
where b.CALAGE is NULL; 

/*Empty table for date-selection*/
create table dates_wo select * from dates where 1=0;

/*exclude oldest dates of each site*/
/*insert into dates_wo*/
select *
from dates c
where c.LABNR <> all(select a.LABNR
                 from dates a
                 left join dates b
                 on a.SITE = b.SITE and a.CALAGE < b.CALAGE
                 where b.CALAGE is NULL)

/*exclude oldest and second oldets dates of each site
-> needs dates_wo*/
select *
from dates_wo c
where c.LABNR <> all(select a.LABNR
                 from dates_wo a
                 left join dates_wo b
                 on a.SITE = b.SITE and a.CALAGE < b.CALAGE
                 where b.CALAGE is NULL);

                 
  