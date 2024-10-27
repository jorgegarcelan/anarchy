model anarchy_game

global{
	// Variables globales
	
	// Parametros del juego: Conocimiento común que comparten 
	// todos los agentes y pertenecen a la ontología
	int recurso_caballeros <- 50;
    int recurso_cultura <- 50;
    int recurso_magia <- 50;
    int recurso_oro <- 50;
	
	
	// Roles
	string Reino_rol <- "Reino";
	string Jugador_rol <- "Jugador";
	
	// Acciones
	string proponer_alianza <- "Proponer_Alianza";
	string aceptar_alianza <- "Aceptar_Alianza";
	string rechazar_alianza <- "Rechazar_Alianza";
	
	// Predicados
	
	// Conceptos
	string num_oro <- "Numero_Oro";
    string num_cultura <- "Numero_Cultura";
    string num_magia <- "Numero_Magia";
    string num_caballeros <- "Numero_Caballeros";
    
	init {
		create df number: 1;
		create reino number: 1;
	    create Jugador number: 1 {
	      rol <- "Anarquista";
	      id <- 1;           
	      anarquistas <-  map([2::false, 3::false]);
	    }
	
	    create Jugador number: 1 {
	      rol <- "Economista";
	      id <- 2;           
	      anarquistas <-  map([1::true, 3::false]);
	    }	
	    
	    create Jugador number: 1 {
	      rol <- "Hechicero";
	      id <- 3;           
	      anarquistas <-  map([1::true, 2::false]);
	    }
	}
	
	
}

species df{
	list<pair> yellow_pages <- []; 
    // to register an agent according to his role
    bool register(string the_role, agent the_agent) {
	  	bool registered;
	  	add the_role::the_agent to: yellow_pages;
	  	return registered;
  	}
  	
    // to search agents according to the role
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


species Jugador skills: [fipa] control: simple_bdi {
	int id;
	string rol;
	map<int,bool> anarquistas;
	
	bool alianza_propuesta <- false;
	
	list<Jugador> jugadores;
	// deseos de los jugadores
	predicate pedir_proponer_alianza <- new_predicate("pedir_alianza");
	
	init {
		ask df{
			bool registrado <- register(Jugador_rol, myself);
		}
	}
	
	plan plan_proponer_alianza intention: pedir_proponer_alianza{
			// manda el mensaje de request proponer alianza al jugador i
			ask df{
				list<Jugador> todos_jugadores  <- search("Jugador");
				list<Jugador> jugadores_filtrados <- [];
				write("Jugadores encontrados en df: " + todos_jugadores);
				
				  // Loop through all_players using an indexed loop and add only those that are not myself
				loop i from: 0 to: (length(todos_jugadores)-1 ) {
					Jugador candidato <- todos_jugadores at i;
					    if (candidato != myself) {
					    
					      add item: candidato to: jugadores_filtrados;
				    }
			    }
			    myself.jugadores <-jugadores_filtrados;
			    write("Jugadores filtrados: " + jugadores_filtrados);
			    
			}
			
			list contenido;
			string accion <- proponer_alianza;
			list lista_conceptos <- [id];
			pair contenido_pair <- accion::lista_conceptos;
			add contenido_pair to: contenido;
			write("antes");
			do start_conversation to: jugadores protocol: 'fipa-request' performative: 'request' contents: contenido;
			write("despues");
			// tienes el deseo de hacer una asamblea cuando dispones de esa carta
			do remove_intention(pedir_proponer_alianza);
			//do remove_desire(pedir_proponer_alianza);
		
	}
	
	reflex receive_request when: !empty(requests){
		// trata el mensaje request proponer_alianza de el jugador
		message request_jugador <- first(requests);
		write 'Jugador ' + id + ' recive un request de un jugador con contenido ' + request_jugador;
		
		list lista_contenidos <- list(request_jugador.contents);
		map contenido_map <- lista_contenidos at 0;
		pair contenido_pair <- contenido_map.pairs at 0;
		string accion <- string(contenido_pair.key);
		list conceptos <- list(contenido_pair.value);
		int id_propuesta <- conceptos at 0;
		//Jugador jugador_propuesta <- request_jugador.sender;
		//int id_propuesta <- jugador_propuesta.id;
		
		bool es_anarquista <- anarquistas[id_propuesta];
		if (es_anarquista) {
			write("Sospecho que el jugador " + id_propuesta + " es anarquista por lo que no acepto la alianza.");
			do refuse message: request_jugador contents: request_jugador.contents;
		} else {
			write("Acepto la alianza con el jugador " + id_propuesta + ".");
			do agree message: request_jugador contents: request_jugador.contents;
		}
		//do inform message: request_jugador contents: request_jugador.contents;
		
	}
	
	reflex receive_inform when: !empty(informs){
		message inform_received <- informs[0];
		
	}
	
	reflex receive_agree when: !empty(agrees){
		// tratar el mensaje agree proponer alianza del protocolo del jugador
		// No se hace nada, se esperaría a la votación
		message agree_received <- agrees[0];
		write("Han aceptado una propuesta de alianza");
	}
	
	reflex receive_refuse when: !empty(refuses){
		// tratar el mensaje agree proponer alianza del protocolo del jugador
		// No se hace nada, se esperaría a la votación
		message refuse_received <- refuses[0];
		write("No han aceptado una propuesta de alianza");
	}
} 


species reino skills: [fipa] control: simple_bdi{
	bool anarquismo <- false;
	int oro <- 50;
	int cultura <- 50;
	int caballeros <- 50;
	int magia <- 50;
	
	init{
		ask df {
            bool registrado <- register(Reino_rol, myself);
        }
		
	}
	
	// recibe query-ref robo_carta_mazo
	
	// aumentar o disminuir recursos
	reflex receive_request when: !empty(requests){
		
	}
}


experiment propose_alliance type: gui {
    init {
    // Ensure the player with id=1 exists and assign the intention
        ask Jugador {
            if (id = 1) {
                do add_intention(pedir_proponer_alianza);
    		}
  		}
	 }
}
