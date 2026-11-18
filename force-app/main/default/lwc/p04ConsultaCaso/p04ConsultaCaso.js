import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import consultar from '@salesforce/apex/P04ConsultaCaso.consultar';

const RESULTADOS = { En_cobertura: 'En cobertura', Fuera_cobertura: 'Fuera de cobertura', Pendiente_datos: 'Pendiente de datos' };
const ESTADOS = { P04_Nuevo: 'Nuevo', P04_EnCurso: 'En curso', P04_PendienteInformacion: 'Pendiente de información', P04_Cerrado: 'Cerrado' };
const campo = (etiqueta, valor, tipo = 'texto') => ({
    etiqueta, valor, texto: valor == null || valor === '' ? 'No consta' : valor,
    fecha: tipo === 'fecha' && Boolean(valor), momento: tipo === 'momento' && Boolean(valor)
});

export default class P04ConsultaCaso extends NavigationMixin(LightningElement) {
    _recordId;
    _solicitud = 0;
    _conectado = false;
    cargando = false;
    datos;
    error;

    @api
    get recordId() { return this._recordId; }
    set recordId(value) {
        if (this._recordId === value) return;
        this._recordId = value;
        this.limpiar();
        if (this._conectado) this.actualizar();
    }

    connectedCallback() { this._conectado = true; this.actualizar(); }
    disconnectedCallback() { this._conectado = false; this.limpiar(); }

    limpiar() {
        this._solicitud += 1;
        this.datos = undefined;
        this.error = undefined;
        this.cargando = false;
    }

    async actualizar() {
        this.limpiar();
        const solicitud = this._solicitud;
        const caseId = this._recordId;
        if (!caseId) return;
        this.cargando = true;
        try {
            const respuesta = await consultar({ caseId });
            if (!this._conectado || solicitud !== this._solicitud) return;
            if (respuesta?.codigo === 'OK' && respuesta.caso && respuesta.producto && Array.isArray(respuesta.relacionados)) {
                this.datos = respuesta;
            } else {
                this.error = respuesta?.codigo === 'NO_DISPONIBLE'
                    ? 'Consulta no disponible. Comprueba el acceso al caso, al producto y a los campos de posventa.'
                    : 'No se pudo completar la consulta. Pulsa Actualizar para reintentar.';
            }
        } catch {
            if (this._conectado && solicitud === this._solicitud) {
                this.error = 'No se pudo completar la consulta. Pulsa Actualizar para reintentar.';
            }
        } finally {
            if (this._conectado && solicitud === this._solicitud) this.cargando = false;
        }
    }

    get resultado() { return RESULTADOS[this.datos?.caso.resultado] || 'Sin evaluar'; }
    get aviso() {
        const c = this.datos.caso;
        const p = this.datos.producto;
        if (c.cerrado) return 'Caso cerrado: evaluación histórica conservada. Los datos actuales del producto pueden haber cambiado.';
        if (!c.resultado) return 'Sin evaluar. Utiliza la acción Evaluar garantía y después pulsa Actualizar.';
        // Compara fechas y ausencias; no calcula cobertura ni autoriza el cierre.
        const iguales = (a, b) => (a ?? null) === (b ?? null);
        if (!iguales(c.compra, p.compra) || !iguales(c.inicio, p.inicio) || !iguales(c.fin, p.fin) || !iguales(c.incidenciaEvaluada, c.incidencia)) {
            return 'Las fechas han cambiado: requiere reevaluación antes del cierre. Utiliza Evaluar garantía y después Actualizar.';
        }
        if (c.resultado === 'Pendiente_datos') return 'Evaluación realizada con información incompleta. No equivale a Sin evaluar.';
        return 'Evaluación registrada. Este panel no recalcula la garantía ni autoriza el cierre.';
    }
    get actuales() {
        const p = this.datos.producto;
        return [campo('Producto', p.nombre), campo('Número de serie', p.serie), campo('Fecha de compra actual', p.compra, 'fecha'),
            campo('Inicio de garantía actual', p.inicio, 'fecha'), campo('Fin de garantía actual', p.fin, 'fecha'),
            campo('Fecha de incidencia del caso', this.datos.caso.incidencia, 'fecha')];
    }
    get instantanea() {
        const c = this.datos.caso;
        return [campo('Motivo registrado', c.motivo), campo('Compra utilizada', c.compra, 'fecha'),
            campo('Inicio utilizado', c.inicio, 'fecha'), campo('Fin utilizado', c.fin, 'fecha'),
            campo('Incidencia utilizada', c.incidenciaEvaluada, 'fecha'), campo('Momento de evaluación', c.evaluadaEl, 'momento')];
    }
    get relacionados() { return this.datos.relacionados.map(c => ({ ...c, estado: ESTADOS[c.Status] || c.Status, enlace: `Abrir caso ${c.CaseNumber}` })); }
    get hayRelacionados() { return this.datos.relacionados.length > 0; }

    navegar(event) {
        const recordId = event.currentTarget.dataset.id;
        if (!this.datos?.relacionados.some(c => c.Id === recordId)) return;
        this[NavigationMixin.Navigate]({ type: 'standard__recordPage', attributes: { recordId, objectApiName: 'Case', actionName: 'view' } });
    }
}
