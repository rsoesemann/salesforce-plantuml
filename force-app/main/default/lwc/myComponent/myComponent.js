import { LightningElement } from "lwc";

export default class myComponents extends LightningElement {
    connectedCallback() {
        setTimeout(() => {
            const el = this.template.querySelector('span');
            // ... manipulating the span LightningElement
        });
    }
}