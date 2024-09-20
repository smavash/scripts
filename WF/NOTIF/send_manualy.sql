begin
  fnd_client_info.setup_client_info(20003,50293,1134,0);
  xxau_util_pkg.send_mail(p_subject => 'Try sending mail',
                          p_body => 'Try sending mail - Body.',
                          p_users => 'SMAVASH');
  commit;
end;
