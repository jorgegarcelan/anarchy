model anarchy_game

global {
  // Parámetros de configuración
  int caballeros <- 50;
  int cultura <- 50;
  int magia <- 50;
  int oro <- 50;
  
  int cycles;
  int cycles_to_pause <- 5;
  bool game_over <- false;
  
  // Conocimiento común que comparten todos los agentes y pertenecen a la ontología
  // - Roles
  string Anarquista_rol <- "Anarquista";
  string Economista_rol <- "Economista";
  string Hechicero_rol <- "Hechicero";
  string General_rol <- "General";
  string Cosmopolita_rol <- "Cosmopolita";
  
  // - Acciones
  	string aumentar_caballeros <- "Aumentar_Caballeros";
  	string aumentar_cultura <- "Aumentar_Cultura";
  	string aumentar_magia <- "Aumentar_Magia";
  	string aumentar_oro <- "Aumentar_Oro";
  	
	string reducir_caballeros <- "Reducir_Caballeros";
	string reducir_cultura <- "Reducir_Cultura";
	string reducir_magia <- "Reducir_Magia";
	string reducir_oro <- "Reducir_Oro";
	
	string excluir_jugador <- "Excluir_Jugador";
	string convocar_asamblea <- "Convocar_Asamblea";
	string proponer_alianza <- "Proponer_Alianza";
	string aceptar_alianza <- "Aceptar_Alianza";
	string rechazar_alianza <- "Rechazar_Alianza";
	string disolver_alianza <- "Disolver_Alianza";
	string incito_votar_a <- "Incito_Votar_A";
	string negar_votar_a <- "Negar_Votar_A";
	string aceptar_votar_a <- "Aceptar_Votar_A";

	string incito_reducir_caballeros <- "Incito_reducir_Caballeros";
	string incito_reducir_cultura <- "Incito_reducir_Cultura";
	string incito_reducir_magia <- "Incito_reducir_Magia";
	string incito_reducir_oro <- "Incito_reducir_Oro";
	
	string incito_aumentar_caballeros <- "Incito_Aumentar_Caballeros";
	string incito_aumentar_cultura <- "Incito_Aumentar_Cultura";
	string incito_aumentar_magia <- "Incito_Aumentar_Magia";
	string incito_aumentar_oro <- "Incito_Aumentar_Oro";
	
	string aceptar_reducir_caballeros <- "Aceptar_Reducir_Caballeros";
	string aceptar_reducir_cultura <- "Aceptar_Reducir_Cultura";
	string aceptar_reducir_magia <- "Aceptar_Reducir_Magia";
	string aceptar_reducir_oro <- "Aceptar_Reducir_Oro";
	
	string negar_reducir_caballeros <- "Negar_Reducir_Caballeros";
	string negar_reducir_cultura <- "Negar_Reducir_Cultura";
	string negar_reducir_magia <- "Negar_Reducir_Magia";
	string negar_reducir_oro <- "Negar_Reducir_Oro";
	
	string aceptar_aumentar_caballeros <- "Aceptar_Aumentar_Caballeros";
	string aceptar_aumentar_cultura <- "Aceptar_Aumentar_Cultura";
	string aceptar_aumentar_magia <- "Aceptar_Aumentar_Magia";
	string aceptar_aumentar_oro <- "Aceptar_Aumentar_Oro";
	
	string negar_aumentar_caballeros <- "Negar_Aumentar_Caballeros";
	string negar_aumentar_cultura <- "Negar_Aumentar_Cultura";
	string negar_aumentar_magia <- "Negar_Aumentar_Magia";
	string negar_aumentar_oro <- "Negar_Aumentar_Oro";
	
// - Predicados
	string robo_carta_rol <- "Robo_Carta_Rol";
	string robo_carta_mazo <- "Robo_Carta_Mazo";
	string juego_carta <- "Juego_Carta";
	string nomino_jugador <- "Nomino_Jugador";
	string jugador_asesinado <- "Jugador_Asesinado";
	string miro_carta <- "Miro_Carta";
	string pregunta_voto <- "Pregunta_Voto";
	string resultado_votacion <- "Resultado_Votacion";
  
  // - Conceptos		 	
	init {
		// creamos los agentes
			create species:df number:1;
			create species:reino number:1;
			create species:anarquista number:1;
			create species:hechicero number:1;
			create species:economista number:1;
			create species:general number:1;
			create species:cosmopolita number:1;
	}
	
	// ciclos
	reflex counting {
		cycles <- cycles+1;
	}
	
	// permite observar paso a paso
	reflex pausing when: cycles = cycles_to_pause {
		write "pausing simulation";
		cycles <- 0;
		do pause;
	}
	
	// para finalizar simulación
	reflex halting when: game_over {
		write "halting simulation";
		do die;
	}
}

// directory facilitator to allow agents meet first time from the role they used when they register -- Beers.gaml
species df {
  list<pair> yellow_pages <- []; 
  // to register an agent according to his role
  bool register(string the_role, agent the_agent) {
  	bool registered;
  	add the_role::the_agent to: yellow_pages;
  	return registered;
  }
  // to search agents accoding to the role
  list search(string the_role) {
  	list<agent> found_ones <- [];
	loop i from:0 to: (length(yellow_pages)-1) {
		pair candidate <- yellow_pages at i;
		if (candidate.key = the_role) {
			add item:candidate.value to: found_ones; }
		} 
	return found_ones;	
	} 
}
