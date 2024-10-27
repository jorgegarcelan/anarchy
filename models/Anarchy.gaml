model anarchy_game

global{
	// Variables globales
	bool game_over <- false;
	int cycles;
	int cycles_to_pause <- 4;
	
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
	
	string aumentar_caballeros <- "Aumentar_Caballeros";
  	string aumentar_cultura <- "Aumentar_Cultura";
  	string aumentar_magia <- "Aumentar_Magia";
  	string aumentar_oro <- "Aumentar_Oro";
  	
	string reducir_caballeros <- "Reducir_Caballeros";
	string reducir_cultura <- "Reducir_Cultura";
	string reducir_magia <- "Reducir_Magia";
	string reducir_oro <- "Reducir_Oro";
	
	// Conceptos
	string num_oro <- "Numero_Oro";
    string num_cultura <- "Numero_Cultura";
    string num_magia <- "Numero_Magia";
    string num_caballeros <- "Numero_Caballeros";
    
	init {
		create df number: 1;
		create Reino number: 1;
	    create Jugador number: 1 {
	      rol <- "Anarquista";
	      id <- 1;          
	      // Modelamos las creencias sobre el resto de jugadores 
	      anarquistas <- map([2::false, 3::false]);
	    }
	
	    create Jugador number: 1 {
	      rol <- "Economista";
	      id <- 2; 
	      // Modelamos las creencias sobre el resto de jugadores           
	      anarquistas <-  map([1::true, 3::false]);
	    }	
	    
	    create Jugador number: 1 {
	      rol <- "Hechicero";
	      id <- 3; 
	      // Modelamos las creencias sobre el resto de jugadores             
	      anarquistas <-  map([1::false, 2::false]);
	    }
	}
	
	reflex counting{
		cycles <- cycles + 1;
	}
	
	reflex pausing when: cycles = cycles_to_pause{
		//write ("Terminar iteración");
		cycles <- 0;
		do die;
	}
	
	// Finalizar el juego
	reflex halting when: game_over {
		write "El reino ha caído en anarquía";
		do die;
	}
	
}

species df{
	list<pair> yellow_pages <- []; 
    // Registrar al agente de acuerdo a su rol
    bool register(string the_role, agent the_agent) {
	  	bool registered;
	  	add the_role::the_agent to: yellow_pages;
	  	return registered;
  	}
  	
    // Buscar agentes dependiento de su rol
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
	int id; // identificador del jugador
	string rol; // rol
	map<int,bool> anarquistas; // creencias sobre el resto de jugadores
		
	list<Reino> mi_reino; // conocimiento sobre el reino
	// Creencia sobre cantidad de recursos a aumentar o reducir tras haber jugado una carta de eventos
	int cantidad_aumentar_reducir <- 55;	
	
	list<Jugador> jugadores;
	// Deseos de los jugadores
	predicate pedir_proponer_alianza <- new_predicate("pedir_alianza");
	predicate pedir_aumentar_oro <- new_predicate("aumentar_oro");
	predicate pedir_reducir_oro <- new_predicate("reducir_oro");
	predicate pedir_aumentar_caballeros <- new_predicate("aumentar_caballeros");
	predicate pedir_reducir_caballeros <- new_predicate("reducir_caballeros");
	predicate pedir_aumentar_cultura <- new_predicate("aumentar_cultura");
	predicate pedir_reducir_cultura <- new_predicate("reducir_cultura");
	predicate pedir_aumentar_magia <- new_predicate("aumentar_magia");
	predicate pedir_reducir_magia <- new_predicate("reducir_magia");
	
	init {
		ask df{
			bool registrado <- register(Jugador_rol, myself);
		}
	}
	
	
	// ----------------- Oro ------------------
	plan plan_aumentar_oro intention: pedir_aumentar_oro{
		// Manda el mensaje de request para aumentar el oro del reino
		ask df{
			myself.mi_reino  <- search("Reino");			
		}
		
		list contenido;
		string accion <- aumentar_oro;
		// El concepto de la accion 'aumentar_oro' es la cantidad de oro a aumentar
		list lista_conceptos <- [cantidad_aumentar_reducir];
		pair contenido_pair <- accion::lista_conceptos;
		add contenido_pair to: contenido;
		do start_conversation to: mi_reino  protocol: 'fipa-request' performative: 'request' contents: contenido;
		// Borramos los deseos del jugador
		do remove_intention(pedir_aumentar_oro);
		do remove_desire(pedir_aumentar_oro);
		
	}
	
	plan plan_reducir_oro intention: pedir_reducir_oro{
		// Manda el mensaje de request para reducir el oro en el reino
		ask df{
			myself.mi_reino  <- search("Reino");					
		}
			
		list contenido;
		string accion <- reducir_oro;
		// El concepto de la accion 'reducir_oro' es la cantidad de oro a reducir
		list lista_conceptos <- [cantidad_aumentar_reducir];
		pair contenido_pair <- accion::lista_conceptos;
		add contenido_pair to: contenido;
		do start_conversation to: mi_reino  protocol: 'fipa-request' performative: 'request' contents: contenido;
		// Borramos los deseos del jugador
		do remove_intention(pedir_reducir_oro);
		do remove_desire(pedir_reducir_oro);
	
	}
	
	// ----------------- Caballeros ------------------
	plan plan_aumentar_caballeros intention: pedir_aumentar_caballeros{
		// Manda el mensaje de request para aumentar los caballeros del reino
		ask df{
			myself.mi_reino  <- search("Reino");			
		}
		
		list contenido;
		string accion <- aumentar_caballeros;
		// El concepto de la accion 'aumentar_caballeros' es la cantidad de caballeros a aumentar
		list lista_conceptos <- [cantidad_aumentar_reducir];
		pair contenido_pair <- accion::lista_conceptos;
		add contenido_pair to: contenido;
		do start_conversation to: mi_reino  protocol: 'fipa-request' performative: 'request' contents: contenido;
		// Borramos los deseos del jugador
		do remove_intention(pedir_aumentar_caballeros);
		do remove_desire(pedir_aumentar_caballeros);
		
	}
	
	plan plan_reducir_caballeros intention: pedir_reducir_caballeros{
		// Manda el mensaje de request para reducir el caballeros en el reino
		ask df{
			myself.mi_reino  <- search("Reino");					
		}
			
		list contenido;
		string accion <- reducir_caballeros;
		// El concepto de la accion 'reducir_caballeros' es la cantidad de oro a reducir
		list lista_conceptos <- [cantidad_aumentar_reducir];
		pair contenido_pair <- accion::lista_conceptos;
		add contenido_pair to: contenido;
		do start_conversation to: mi_reino  protocol: 'fipa-request' performative: 'request' contents: contenido;
		// Borramos los deseos del jugador
		do remove_intention(pedir_reducir_caballeros);
		do remove_desire(pedir_reducir_caballeros);
	
	}
	
	// ----------------- Magia ------------------
	plan plan_aumentar_magia intention: pedir_aumentar_magia{
		// Manda el mensaje de request para aumentar la magia del reino
		ask df{
			myself.mi_reino  <- search("Reino");			
		}
		
		list contenido;
		string accion <- aumentar_magia;
		// El concepto de la accion 'aumentar_magia' es la cantidad de magia a aumentar
		list lista_conceptos <- [cantidad_aumentar_reducir];
		pair contenido_pair <- accion::lista_conceptos;
		add contenido_pair to: contenido;
		do start_conversation to: mi_reino  protocol: 'fipa-request' performative: 'request' contents: contenido;
		// Borramos los deseos del jugador
		do remove_intention(pedir_aumentar_magia);
		do remove_desire(pedir_aumentar_magia);
		
	}
	
	plan plan_reducir_magia intention: pedir_reducir_magia{
		// Manda el mensaje de request para reducir la magia en el reino
		ask df{
			myself.mi_reino  <- search("Reino");					
		}
			
		list contenido;
		string accion <- reducir_magia;
		// El concepto de la accion 'reducir_magia' es la cantidad de magia a reducir
		list lista_conceptos <- [cantidad_aumentar_reducir];
		pair contenido_pair <- accion::lista_conceptos;
		add contenido_pair to: contenido;
		do start_conversation to: mi_reino  protocol: 'fipa-request' performative: 'request' contents: contenido;
		// Borramos los deseos del jugador
		do remove_intention(pedir_reducir_magia);
		do remove_desire(pedir_reducir_magia);
	
	}
	
	// ----------------- Cultura ------------------
	plan plan_aumentar_cultura intention: pedir_aumentar_cultura{
		// Manda el mensaje de request para aumentar la cultura del reino
		ask df{
			myself.mi_reino  <- search("Reino");			
		}
		
		list contenido;
		string accion <- aumentar_cultura;
		// El concepto de la accion 'aumentar_cultura' es la cantidad de cultura a aumentar
		list lista_conceptos <- [cantidad_aumentar_reducir];
		pair contenido_pair <- accion::lista_conceptos;
		add contenido_pair to: contenido;
		do start_conversation to: mi_reino  protocol: 'fipa-request' performative: 'request' contents: contenido;
		// Borramos los deseos del jugador
		do remove_intention(pedir_aumentar_cultura);
		do remove_desire(pedir_aumentar_cultura);
		
	}
	
	plan plan_reducir_cultura intention: pedir_reducir_cultura{
		// Manda el mensaje de request para reducir la magia en el reino
		ask df{
			myself.mi_reino  <- search("Reino");					
		}
			
		list contenido;
		string accion <- reducir_cultura;
		// El concepto de la accion 'reducir_cultura' es la cantidad de cultura a reducir
		list lista_conceptos <- [cantidad_aumentar_reducir];
		pair contenido_pair <- accion::lista_conceptos;
		add contenido_pair to: contenido;
		do start_conversation to: mi_reino  protocol: 'fipa-request' performative: 'request' contents: contenido;
		// Borramos los deseos del jugador
		do remove_intention(pedir_reducir_cultura);
		do remove_desire(pedir_reducir_cultura);
	
	}

	reflex receive_inform when: !empty(informs){
		// Recibe los Inform-Done de los demás jugadores/reino
		message inform_received <- informs[0];
		
	}
	
	plan plan_proponer_alianza intention: pedir_proponer_alianza{
		write("Jugador " + id + "va a proponer una alianza a los demás jugadores.");
		// Manda el mensaje de request proponer alianza a los demás jugadores
		ask df{
			list<Jugador> todos_jugadores  <- search("Jugador");
			list<Jugador> jugadores_filtrados <- [];
			write("\tJugadores encontrados en df: " + todos_jugadores);
			
			// Bucle para iterar sobre todos los jugadores menos yo
			loop i from: 0 to: (length(todos_jugadores)-1 ) {
				Jugador candidato <- todos_jugadores at i;
				    if (candidato != myself) {
				      add item: candidato to: jugadores_filtrados;
			    }
		    }
		    myself.jugadores <-jugadores_filtrados;
		    write("\tJugadores a los que enviar la propuesta de alianza: " + jugadores_filtrados);
		    
		}
		
		list contenido;
		string accion <- proponer_alianza;
		list lista_conceptos <- [];
		pair contenido_pair <- accion::lista_conceptos;
		add contenido_pair to: contenido;
		do start_conversation to: jugadores protocol: 'fipa-request' performative: 'request' contents: contenido;
		// Tienes el deseo de hacer una asamblea cuando dispones de esa carta
		do remove_intention(pedir_proponer_alianza);
		do remove_desire(pedir_proponer_alianza);
		
	}
	
	reflex receive_request when: !(empty(requests)){
		// trata el mensaje request proponer_alianza de el jugador
		message request_jugador <- first(requests);
		write 'Jugador ' + id + ' recibe un request de un jugador con contenido ' + request_jugador;
		
		list lista_contenidos <- list(request_jugador.contents);
		map contenido_map <- lista_contenidos at 0;
		pair contenido_pair <- contenido_map.pairs at 0;
		string accion <- string(contenido_pair.key);
		list conceptos <- list(contenido_pair.value);
		Jugador jugador_propuesta <- request_jugador.sender;
		int id_propuesta <- jugador_propuesta.id;
		
		bool es_anarquista <- anarquistas[id_propuesta];
		if (es_anarquista) {
			write("\tSospecho que el jugador " + id_propuesta + " es anarquista por lo que no acepto la alianza.");
			do refuse message: request_jugador contents: request_jugador.contents;
			
		} else {
			write("\tSospecho que el jugador " + id_propuesta + " no es anarquista por lo que acepto la alianza con él.");
			do agree message: request_jugador contents: request_jugador.contents;
		
		}
		do inform message: request_jugador contents: request_jugador.contents;
		
	}
	
	
	reflex receive_agree when: !(empty(agrees)){
		// Tratar el mensaje agree proponer alianza del protocolo del jugador
		message agree_received <- agrees[0];
		write("Han aceptado una propuesta de alianza");
	}
	
	reflex receive_refuse when: !empty(refuses){
		// Tratar el mensaje refuse proponer alianza del protocolo del jugador
		message refuse_received <- refuses[0];
		write("No han aceptado una propuesta de alianza");
	}
	
	
	reflex receive_inform when: !(empty(informs)){
		message inform_received <- informs[0];
		write('Inform recibido.');
		do remove_intention(pedir_proponer_alianza);
		do remove_desire(pedir_proponer_alianza);
	}
} 


species Reino skills: [fipa] control: simple_bdi{
	bool anarquismo <- false;
	int recurso_oro <- 50;
	int recurso_cultura <- 50;
	int recurso_caballeros <- 50;
	int recurso_magia <- 50;
	
	init{
		ask df {
            bool registrado <- register(Reino_rol, myself);
        }
		
	}
		
	reflex receive_request when: !empty(requests) {
		// Código para procesar mensaje request del jugador
		message requestFromJugador <- requests[0];
		write 'El reino recibe un request del jugador '+ requestFromJugador.sender +' con el contenido ' + requestFromJugador.contents;
		// Procesar la solicitud
		
		// - Extraer contenido del mensaje
		list contentList <- list(requestFromJugador.contents);
		map content_map <- contentList at 0;
		pair content_pair <- content_map.pairs at 0;
		string accion <- string(content_pair.key); // la acción solicitada ([aumentar|reducir]_[caballeros, oro, clutura, magia])
		list conceptos <- list(content_pair.value);
		int valor_cambio <- conceptos at 0;
		write("\tRecursos actuales del reino:");
		write("\t\tOro: " + recurso_oro);	
		write("\t\tCaballeros: " + recurso_caballeros);
		write("\t\tMagia: " + recurso_magia);
		write("\t\tCultura: " + recurso_cultura);	
		write("\tAccion: " + accion);
		write("\tValor a aumentar o reducir: " + valor_cambio);
		
		// - Dependiendo de la acción, procesamos la solicitud
		if (accion = aumentar_caballeros) {
			recurso_caballeros <- recurso_caballeros + valor_cambio;
			write ("\tReino aumenta los caballeros en " + valor_cambio + ". Nuevo valor: " + recurso_caballeros);
		}
		else if (accion = aumentar_oro) {
			recurso_oro <- recurso_oro + valor_cambio;
			write ("\tReino aumenta el oro en " + valor_cambio + ". Nuevo valor: " + recurso_oro);
		}
		else if (accion = aumentar_magia) {
			recurso_magia <- recurso_magia + valor_cambio;
			write ("\tReino aumenta la magia en " + valor_cambio + ". Nuevo valor: " + recurso_magia);
		}
		else if (accion = aumentar_cultura) {
			recurso_cultura <- recurso_cultura + valor_cambio;
			write ("\tReino aumenta la cultura en " + valor_cambio + ". Nuevo valor: " + recurso_cultura);
		}
		else if (accion = reducir_caballeros) {
			recurso_caballeros <- max(0, recurso_caballeros - valor_cambio);
			write ("\tReino disminuye los caballeros en " + valor_cambio + ". Nuevo valor: " + recurso_caballeros);
			if (recurso_caballeros = 0){
				game_over <- true;
			}
		}
		else if (accion = reducir_oro) {
			recurso_oro <- max(0, recurso_oro - valor_cambio);
			write ("\tReino disminuye el oro en " + valor_cambio + ". Nuevo valor: " + recurso_oro);
			if (recurso_oro = 0){
				game_over <- true;
			}
		}
		else if (accion = reducir_magia) {
			recurso_magia <- max(0, recurso_magia - valor_cambio);
			write ("\tReino disminuye la magia en " + valor_cambio + ". Nuevo valor: " + recurso_magia);
			if (recurso_caballeros = 0){
				game_over <- true;
			}
		}
		else if (accion = reducir_cultura) {
			recurso_cultura <- max(0, recurso_cultura - valor_cambio);
			write ("\tReino disminuye la cultura en " + valor_cambio + ". Nuevo valor: " + recurso_cultura);
			if (recurso_cultura = 0){
				game_over <- true;
			}
		}
		// Enviar confirmación al jugador del cambio aplicado mediante inform
		do inform message: requestFromJugador contents: requestFromJugador.contents;
	}
}

// En este experimento el Jugador 1 propone una alianza a los demás jugadores.
// Si se hubiese modelado todo el juego esto debería hacerse después de convocar una asamblea.
experiment propose_alliance type: gui {
    init {
        ask Jugador {
            if (id = 1) {
                do add_intention(pedir_proponer_alianza);
    		}
  		}
	 }
}

// En este experimento el Jugador 1 hace un request al reino para aumentar el oro.
// Si se hubiera modelado todo el juego esto debería hacerse después de una carta de estatutos.
experiment propose_aumentar_oro type: gui {
    init {
        ask Jugador {
            if (id = 1) {
                do add_intention(pedir_aumentar_oro);
    		}
  		}
	 }
}

// En este experimento el Jugador 1 hace un request al reino para reducir el oro. Está hecho para que la cantidad
// a reducir sea mayor a la cantidad de oro que hay en el reino por lo que se cae en anarquía.
// Si se hubiera modelado todo el juego esto debería hacerse después de una carta de estatutos o de desastres.
experiment propose_reducir_oro type: gui {
    init {
        ask Jugador {
            if (id = 1) {
                do add_intention(pedir_reducir_oro);
    		}
  		}
	 }
}
