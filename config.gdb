set breakpoint pending on
set startup-quietly on
set confirm off

file ./dmc
break drewno_mars::Err::report
commands
	where
end
break drewno_mars::InternalError::InternalError
commands
	where
end
break drewno_mars::ToDoError::ToDoError
commands
	where
end

define p5
  set args p5_tests/$arg0.dm -c
  run
end
