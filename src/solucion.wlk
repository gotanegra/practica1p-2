class Vikingo {
	var castaSocial
	var armas
	var oro
	
	method tieneArmas() = armas > 0
	method cambiarCasta(nuevaCasta) { castaSocial = nuevaCasta } 
	method condicionParaExpedicion() = self.esProductivo() && castaSocial.puedeIrAExpedicion(self)
	method esProductivo()
	method agregarOro(cantidad) { oro += cantidad }
	method ascender() { castaSocial.ascenderEscalaSocial(self) }
	method obtenerCasta() = castaSocial //para los test
}

class Soldado inherits Vikingo {
	var vidasCobradas = 0
	override method esProductivo() = self.tieneArmas() && vidasCobradas > 20
	method beneficiosAlSubirAKarl() { armas += 10}
}

class Granjero inherits Vikingo {
	var hectareas
	var cantidadHijos
	
	override method esProductivo() = hectareas <= cantidadHijos * 2
	method beneficiosAlSubirAKarl() { 
		hectareas += 2
		cantidadHijos += 2
	}
}

object jarl {
	method puedeIrAExpedicion(vikingo) = not vikingo.tieneArmas()
	method ascenderEscalaSocial(vikingo) {
		vikingo.cambiarCasta(karl)
		vikingo.beneficiosAlSubirAKarl()
	}
}

object karl {
	method puedeIrAExpedicion(vikingo) = true
	method ascenderEscalaSocial(vikingo) { vikingo.cambiarCasta(thrall) }
}

object thrall {
	method puedeIrAExpedicion(vikingo) = true
	method ascenderEscalaSocial(vikingo) {}
}

class Expedicion {
	var listaObjetivos = []
	var participantes = []
	method valeLaPena() = listaObjetivos.all({ unObjetivo => unObjetivo.valeLaPena() })
	method cantidadParticipantes() = participantes.size()
	method subirAExpedicion(vikingo) { 
		if(not vikingo.condicionParaExpedicion())
		self.error("El vikingo no puede subirse a una expedicion")
		participantes.add(vikingo)
	}
	method invadir(objetivo) { objetivo.serInvadida(self) }
	method realizarExpedicion() {
		listaObjetivos.forEach({ unObjetivo => self.invadir(unObjetivo) })
		participantes.forEach({ unParticipante => unParticipante.agregarOro(self.oroEquitativo())})
	}
	method oroTotal() =	listaObjetivos.sum({ unObjetivo => unObjetivo.monedasDeOro() })
	method oroEquitativo() = self.oroTotal() / self.cantidadParticipantes()
}

class Capital {
	var expedicion
	var factorRiqueza
	var defensores
	method serInvadida(expedicionQueInvade) { 
		expedicion = expedicionQueInvade
		defensores =- self.defensoresDerrotados()
	} 
	method valeLaPena() = self.monedasDeOro() >= 3 * expedicion.cantidadParticipantes()
	method monedasDeOro() = self.defensoresDerrotados() * factorRiqueza
	method defensoresDerrotados() = expedicion.cantidadParticipantes()
}

class Aldea {
	var expedicion
	var crucifijos
	method valeLaPena() = self.saciaSedSaqueos()
	method saciaSedSaqueos() = self.monedasDeOro() >= 15
	method monedasDeOro() = crucifijos
	method serInvadida(expedicionQueInvade) { crucifijos = 0 }
}

class AldeaAmurallada inherits Aldea {
	var vikingosNecesarios
	override method valeLaPena() = super() && expedicion.cantidadParticipantes() >= vikingosNecesarios	
}

//Punto 4: se puede agregar si cambiar absolutamente nada. Solo se necesita crear la clase castillo con los metodos polimorficos valeLaPena(), 
//monedasDeOro() y serInvadida()