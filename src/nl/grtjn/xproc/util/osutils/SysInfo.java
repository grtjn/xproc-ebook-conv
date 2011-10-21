package nl.grtjn.xproc.util.osutils;

import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcConstants;
import com.xmlcalabash.runtime.XAtomicStep;
import com.xmlcalabash.util.TreeWriter;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;

import java.util.Properties;
import java.util.Enumeration;

public class SysInfo extends DefaultStep {
    private static final QName c_info = new QName("c", XProcConstants.NS_XPROC_STEP, "info");
    private static final QName _name = new QName("name");
    private static final QName _value = new QName("value");

    private WritablePipe result = null;

    /**
     * Creates a new instance of SysInfo
     */
    public SysInfo(XProcRuntime runtime, XAtomicStep step) {
        super(runtime,step);
    }

    public void setOutput(String port, WritablePipe pipe) {
        result = pipe;
    }

    public void reset() {
        result.resetWriter();
    }

    public void run() throws SaxonApiException {
        super.run();

        TreeWriter tree = new TreeWriter(runtime);
        tree.startDocument(step.getNode().getBaseURI());
        tree.addStartElement(XProcConstants.c_result);
        tree.startContent();

		Properties props = System.getProperties();
		Enumeration e = props.propertyNames();

		while (e.hasMoreElements()) {
			String key = (String) e.nextElement();
            tree.addStartElement(c_info);
            tree.addAttribute(_name, key);
            tree.addAttribute(_value, props.getProperty(key));
            tree.startContent();
            tree.addEndElement();
        }
        
        tree.addEndElement();
        tree.endDocument();

        result.write(tree.getResult());
    }
}