declare

pref_tab fnd_preference.prefs_tab_type;

begin

pref_tab(1).name :='TERRITORY';

pref_tab(1).value :='ISRAEL';

pref_tab(1).action :='U';

fnd_preference. save_changes(p_user_name=>'-WF_DEFAULT-',

p_module_name=>'WF',

p_prefs_tab => pref_tab);

pref_tab(1).name :='LANGUAGE';

pref_tab(1).value :='HEBREW';

pref_tab(1).action :='U';

fnd_preference. save_changes(p_user_name=>'-WF_DEFAULT-',

p_module_name=>'WF',

p_prefs_tab => pref_tab);

end;



select * from fnd_user_preferences t where t.module_name='WF' and t.preference_name='MAILTYPE'
and t.preference_value!='MAILHTML'


declare
cursor c is
select t.user_name
  from fnd_user_preferences t
 where t.module_name = 'WF'
   and t.preference_name = 'MAILTYPE'
   and t.preference_value != 'MAILHTML';

pref_tab fnd_preference.prefs_tab_type;

begin

        pref_tab(1).name :='MAILTYPE';
        pref_tab(1).value :='MAILHTML';
        pref_tab(1).action :='U';
   
     for r in c
      loop
      
                        fnd_preference. save_changes(p_user_name=>r.user_name,
                           p_module_name=>'WF',
                           p_prefs_tab => pref_tab);
    end loop;                       

end;