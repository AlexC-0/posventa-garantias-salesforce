/** Adaptador sin cálculo ni privilegios propios. Correspondencia 1:1 de solicitudes/respuestas. */
public with sharing class P04EvaluarGarantiaAccion {
    public class Solicitud {
        @InvocableVariable(required=true label='Identificador del caso') public String casoId;
    }
    @InvocableMethod(label='Evaluar garantía P04' description='Evaluación explícita de hasta 200 casos abiertos. Lote atómico.')
    public static List<P04Garantia.Resultado> ejecutar(List<Solicitud> solicitudes){
        List<String> ids=new List<String>();
        if(solicitudes!=null)for(Solicitud item:solicitudes)ids.add(item==null?null:item.casoId);
        return P04Garantia.evaluar(ids);
    }
}
