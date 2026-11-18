import { createElement } from 'lwc';
import Consulta from 'c/p04ConsultaCaso';
import consultar from '@salesforce/apex/P04ConsultaCaso.consultar';
import { __navigate } from 'lightning/navigation';

jest.mock('@salesforce/apex/P04ConsultaCaso.consultar', () => ({ default: jest.fn() }), { virtual: true });
jest.mock('lightning/navigation', () => {
    const Navigate = Symbol('Navigate');
    const navigate = jest.fn();
    const NavigationMixin = Base => class extends Base { [Navigate](reference) { navigate(reference); } };
    NavigationMixin.Navigate = Navigate;
    return { NavigationMixin, __navigate: navigate };
});

const ID = '500000000000001AAA';
const OTRO = '500000000000002AAA';
const respuesta = () => ({
    codigo: 'OK',
    caso: { id: ID, cerrado: false, incidencia: '2024-02-20', resultado: 'En_cobertura', motivo: 'Incidencia dentro del intervalo',
        compra: '2024-01-01', inicio: '2024-02-01', fin: '2024-03-01', incidenciaEvaluada: '2024-02-20', evaluadaEl: '2024-02-21T10:00:00.000Z' },
    producto: { nombre: 'Impresora ficticia', serie: 'SERIE-FICTICIA', compra: '2024-01-01', inicio: '2024-02-01', fin: '2024-03-01' },
    relacionados: [{ Id: OTRO, CaseNumber: '00000002', Subject: 'Otro caso visible', Status: 'P04_EnCurso', CreatedDate: '2024-02-19T10:00:00.000Z' }]
});
const flush = async () => { await Promise.resolve(); await Promise.resolve(); await Promise.resolve(); };
const pendiente = () => { let resolve, reject; const promise = new Promise((a, b) => { resolve = a; reject = b; }); return { promise, resolve, reject }; };
function montar(id = ID) { const e = createElement('c-p04-consulta-caso', { is: Consulta }); e.recordId = id; document.body.appendChild(e); return e; }
const texto = e => e.shadowRoot.textContent;
const valores = e => [...e.shadowRoot.querySelectorAll('lightning-formatted-text')].map(n => n.value);
const actualizar = e => e.shadowRoot.querySelector('lightning-button[slot="actions"]').click();

afterEach(() => { while (document.body.firstChild) document.body.removeChild(document.body.firstChild); jest.resetAllMocks(); });

it('indica carga accesible sin mostrar datos anteriores', async () => {
    consultar.mockReturnValue(new Promise(() => {})); const e = montar(); await flush();
    expect(e.shadowRoot.querySelector('lightning-spinner').alternativeText).toContain('Cargando');
    expect(e.shadowRoot.querySelector('[slot="actions"]').disabled).toBe(true);
    expect(e.shadowRoot.querySelector('section')).toBeNull();
});
it('presenta producto actual e instantánea en secciones separadas', async () => {
    consultar.mockResolvedValue(respuesta()); const e = montar(); await flush();
    expect(consultar).toHaveBeenCalledWith({ caseId: ID }); expect(consultar).toHaveBeenCalledTimes(1);
    expect(e.shadowRoot.querySelectorAll('section')).toHaveLength(3);
    expect(valores(e)).toEqual(expect.arrayContaining(['Impresora ficticia', 'SERIE-FICTICIA', 'Incidencia dentro del intervalo']));
    expect(texto(e)).toContain('En cobertura'); expect(texto(e)).toContain('no recalcula');
});
it('formatea Date sin desplazarlo de día y DateTime con zona', async () => {
    consultar.mockResolvedValue(respuesta()); const e = montar(); await flush();
    const fechas = [...e.shadowRoot.querySelectorAll('lightning-formatted-date-time')];
    expect(fechas.filter(n => n.value === '2024-02-20').every(n => n.timeZone === 'UTC')).toBe(true);
    expect(fechas.find(n => n.value === '2024-02-21T10:00:00.000Z').timeZoneName).toBe('short');
});
it('distingue sin evaluar de un resultado registrado', async () => {
    const r = respuesta(); Object.assign(r.caso, { resultado: null, motivo: null, evaluadaEl: null });
    consultar.mockResolvedValue(r); const e = montar(); await flush();
    expect(texto(e)).toContain('Sin evaluar'); expect(texto(e)).toContain('Utiliza la acción Evaluar garantía');
});
it('explica Pendiente_datos con fechas ausentes coincidentes', async () => {
    const r = respuesta(); r.caso.resultado = 'Pendiente_datos'; r.caso.inicio = null; r.producto.inicio = null;
    consultar.mockResolvedValue(r); const e = montar(); await flush();
    expect(texto(e)).toContain('Pendiente de datos'); expect(texto(e)).toContain('información incompleta');
    expect(texto(e)).not.toContain('requiere reevaluación');
});
it.each(['compra', 'inicio', 'fin', 'incidenciaEvaluada'])('avisa cuando cambia %s, incluidas ausencias', async field => {
    const r = respuesta(); r.caso[field] = null;
    consultar.mockResolvedValue(r); const e = montar(); await flush();
    expect(texto(e)).toContain('requiere reevaluación antes del cierre');
});
it('conserva interpretación histórica del cerrado aunque cambie producto', async () => {
    const r = respuesta(); r.caso.cerrado = true; r.producto.fin = '2025-01-01';
    consultar.mockResolvedValue(r); const e = montar(); await flush();
    expect(texto(e)).toContain('Caso cerrado: evaluación histórica conservada');
    expect(texto(e)).not.toContain('requiere reevaluación');
    expect(e.shadowRoot.querySelector('[data-result]').textContent).toBe('En cobertura');
});
it('indica opcionales ausentes sin confundirlos con acceso restringido', async () => {
    const r = respuesta(); r.producto.serie = null; r.producto.compra = null; r.caso.compra = null;
    consultar.mockResolvedValue(r); const e = montar(); await flush();
    expect(valores(e).filter(v => v === 'No consta').length).toBeGreaterThanOrEqual(3);
    expect(e.shadowRoot.querySelector('[role="alert"]')).toBeNull();
});
it('el vacío de relacionados no afirma inexistencia global', async () => {
    const r = respuesta(); r.relacionados = []; consultar.mockResolvedValue(r); const e = montar(); await flush();
    expect(texto(e)).toContain('No hay otros casos visibles de este producto');
    expect(e.shadowRoot.querySelector('.relacionado')).toBeNull();
});
it('navega al relacionado mediante navegación estándar', async () => {
    consultar.mockResolvedValue(respuesta()); const e = montar(); await flush();
    const boton = e.shadowRoot.querySelector('lightning-button[data-id]');
    expect(boton.label).toBe('00000002'); expect(boton.title).toBe('Abrir caso 00000002');
    boton.click(); expect(__navigate).toHaveBeenCalledWith({ type: 'standard__recordPage', attributes: { recordId: OTRO, objectApiName: 'Case', actionName: 'view' } });
    expect(valores(e)).toContain('Otro caso visible'); expect(texto(e)).toContain('En curso');
});
it('Actualizar recupera la evaluación nueva sin conservar el dato previo durante carga', async () => {
    const r = respuesta(); r.caso.resultado = null; const next = pendiente();
    consultar.mockResolvedValueOnce(r).mockReturnValueOnce(next.promise);
    const e = montar(); await flush(); actualizar(e); await flush();
    expect(e.shadowRoot.querySelector('section')).toBeNull(); next.resolve(respuesta()); await flush();
    expect(texto(e)).toContain('En cobertura'); expect(consultar).toHaveBeenCalledTimes(2);
});
it('rechazo de acceso borra el contenido y no muestra detalles internos', async () => {
    consultar.mockResolvedValueOnce(respuesta()).mockResolvedValueOnce({ codigo: 'NO_DISPONIBLE', detalle: 'SELECT secreto' });
    const e = montar(); await flush(); actualizar(e); await flush();
    expect(texto(e)).toContain('Consulta no disponible'); expect(e.shadowRoot.querySelector('section')).toBeNull();
    expect(texto(e)).not.toContain('SELECT'); expect(valores(e)).not.toContain('Impresora ficticia');
});
it('error de transporte permite reintento sin revelar traza', async () => {
    consultar.mockRejectedValueOnce({ body: { message: 'Error interno SELECT secreto', stackTrace: 'traza' } }).mockResolvedValueOnce(respuesta());
    const e = montar(); await flush(); expect(texto(e)).toContain('Pulsa Actualizar para reintentar'); expect(texto(e)).not.toContain('secreto');
    actualizar(e); await flush(); expect(texto(e)).toContain('En cobertura');
});
it.each([{ codigo: 'ERROR_CONSULTA' }, null, { codigo: 'OK' }])('rechaza respuesta no utilizable con mensaje seguro: %j', async r => {
    consultar.mockResolvedValue(r); const e = montar(); await flush();
    expect(texto(e)).toContain('No se pudo completar la consulta'); expect(e.shadowRoot.querySelector('section')).toBeNull();
});
it('al cambiar de caso descarta respuesta tardía del anterior', async () => {
    const a = pendiente(), b = pendiente(); consultar.mockReturnValueOnce(a.promise).mockReturnValueOnce(b.promise);
    const e = montar(); e.recordId = OTRO; const r = respuesta(); r.producto.nombre = 'Producto siguiente'; r.caso.id = OTRO;
    b.resolve(r); await flush(); a.resolve(respuesta()); await flush();
    expect(valores(e)).toContain('Producto siguiente'); expect(valores(e)).not.toContain('Impresora ficticia');
});
it('un error tardío tampoco borra el caso actual', async () => {
    const a = pendiente(); consultar.mockReturnValueOnce(a.promise).mockResolvedValueOnce(respuesta());
    const e = montar(); e.recordId = OTRO; await flush(); a.reject(new Error('viejo')); await flush();
    expect(texto(e)).toContain('En cobertura'); expect(e.shadowRoot.querySelector('[role="alert"]')).toBeNull();
});
it('sin recordId limpia datos y no consulta', async () => {
    consultar.mockResolvedValue(respuesta()); const e = montar(); await flush(); e.recordId = undefined; await flush();
    expect(e.shadowRoot.querySelector('section')).toBeNull(); expect(consultar).toHaveBeenCalledTimes(1);
});
it('al desconectar invalida la petición pendiente y consulta de nuevo al volver', async () => {
    const a = pendiente(); consultar.mockReturnValueOnce(a.promise).mockResolvedValueOnce(respuesta());
    const e = montar(); document.body.removeChild(e); a.resolve({ codigo: 'NO_DISPONIBLE' }); await flush();
    document.body.appendChild(e); await flush(); expect(texto(e)).toContain('En cobertura'); expect(consultar).toHaveBeenCalledTimes(2);
});
