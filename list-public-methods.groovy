#!/bin/bash
//usr/bin/groovy  -cp /opt/gakoci/hooks/spoon.jar -d "$0" "$@"; exit 0

/*
List all public methods in src/main/java using Spoon
*/

import spoon.reflect.declaration.CtClass;
import spoon.reflect.declaration.CtMethod;
import spoon.Launcher;
import spoon.processing.AbstractProcessor;
import spoon.reflect.declaration.ModifierKind;
import groovy.json.JsonSlurper

class Lister extends AbstractProcessor<CtMethod> {
  List result=[]
  boolean isToBeProcessed(CtMethod c) {
    return c.getParent().isTopLevel() && c.getModifiers().contains(ModifierKind.PUBLIC);
  }
  void process(CtMethod c) {
    System.out.println(c.getParent().getSimpleName()+"#"+c.getSignature());
  }
}
def l = new Launcher();
l.addInputResource("src/main/java");
def proc = new Lister();
l.addProcessor(proc);
l.getEnvironment().setNoClasspath(true);
l.run();
