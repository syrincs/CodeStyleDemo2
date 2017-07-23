$ ->
  if gon.current_user
    mixpanel.identify(gon.current_user.id);
    mixpanel.people.set({
      "$email": gon.current_user.email,
      "$created": gon.current_user.created_at,
      "$last_login": new Date(),
      "first_name": gon.current_user.first_name,
      "last_name": gon.current_user.last_name,
    });
