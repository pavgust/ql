import cpp
private import InstructionTag
private import Opcode
private import TranslatedElement
private import TranslatedExpr

abstract class ConditionContext extends TranslatedElement {
  abstract Instruction getChildTrueSuccessor(TranslatedCondition child);

  abstract Instruction getChildFalseSuccessor(TranslatedCondition child);
}

TranslatedCondition getTranslatedCondition(Expr expr) {
  result.getExpr() = expr
}

abstract class TranslatedCondition extends TranslatedElement {
  Expr expr;

  override final string toString() {
    result = expr.toString()
  }

  override final Locatable getAST() {
    result = expr
  }

  final ConditionContext getConditionContext() {
    result = getParent()
  }

  final Expr getExpr() {
    result = expr
  }

  override final Function getFunction() {
    result = expr.getEnclosingFunction()
  }

  final Type getResultType() {
    result = expr.getType().getUnspecifiedType()
  }
}

abstract class TranslatedFlexibleCondition extends TranslatedCondition,
  ConditionContext, TTranslatedFlexibleCondition {
  TranslatedFlexibleCondition() {
    this = TTranslatedFlexibleCondition(expr)
  }

  override final TranslatedElement getChild(int id) {
    id = 0 and result = getOperand()
  }

  override final Instruction getFirstInstruction() {
    result = getOperand().getFirstInstruction()
  }

  override final predicate hasInstruction(Opcode opcode, InstructionTag tag,
    Type resultType, boolean isGLValue) {
    none()
  }

  override final Instruction getInstructionSuccessor(InstructionTag tag,
    EdgeKind kind) {
    none()
  }

  override final Instruction getChildSuccessor(TranslatedElement child) {
    none()
  }

  abstract TranslatedCondition getOperand();
}

class TranslatedParenthesisCondition extends TranslatedFlexibleCondition {
  ParenthesisExpr paren;

  TranslatedParenthesisCondition() {
    paren = expr
  }

  final override Instruction getChildTrueSuccessor(TranslatedCondition child) {
    child = getOperand() and
    result = getConditionContext().getChildTrueSuccessor(this)
  }

  final override Instruction getChildFalseSuccessor(TranslatedCondition child) {
    child = getOperand() and
    result = getConditionContext().getChildFalseSuccessor(this)
  }

  final override TranslatedCondition getOperand() {
    result = getTranslatedCondition(paren.getExpr())
  }
}

class TranslatedNotCondition extends TranslatedFlexibleCondition {
  NotExpr notExpr;

  TranslatedNotCondition() {
    notExpr = expr
  }

  override Instruction getChildTrueSuccessor(TranslatedCondition child) {
    child = getOperand() and
    result = getConditionContext().getChildFalseSuccessor(this)
  }

  override Instruction getChildFalseSuccessor(TranslatedCondition child) {
    child = getOperand() and
    result = getConditionContext().getChildTrueSuccessor(this)
  }
  
  override TranslatedCondition getOperand() {
    result = getTranslatedCondition(notExpr.getOperand().getFullyConverted())
  }
}

abstract class TranslatedNativeCondition extends TranslatedCondition,
  TTranslatedNativeCondition {
  TranslatedNativeCondition() {
    this = TTranslatedNativeCondition(expr)
  }

  override final Instruction getChildSuccessor(TranslatedElement child) {
    none()
  }
}

abstract class TranslatedBinaryLogicalOperation extends
  TranslatedNativeCondition, ConditionContext {
  BinaryLogicalOperation op;

  TranslatedBinaryLogicalOperation() {
    op = expr
  }

  override final TranslatedElement getChild(int id) {
    id = 0 and result = getLeftOperand() or
    id = 1 and result = getRightOperand()
  }

  override final Instruction getFirstInstruction() {
    result = getLeftOperand().getFirstInstruction()
  }

  override final predicate hasInstruction(Opcode opcode, InstructionTag tag,
    Type resultType, boolean isGLValue) {
    none()
  }

  override final Instruction getInstructionSuccessor(InstructionTag tag,
    EdgeKind kind) {
    none()
  }

  final TranslatedCondition getLeftOperand() {
    result = getTranslatedCondition(op.getLeftOperand().getFullyConverted())
  }

  final TranslatedCondition getRightOperand() {
    result = getTranslatedCondition(op.getRightOperand().getFullyConverted())
  }
}

class TranslatedLogicalAndExpr extends TranslatedBinaryLogicalOperation {
  TranslatedLogicalAndExpr() {
    op instanceof LogicalAndExpr
  }

  override Instruction getChildTrueSuccessor(TranslatedCondition child) {
    (
      child = getLeftOperand() and
      result = getRightOperand().getFirstInstruction()
    ) or
    (
      child = getRightOperand() and
      result = getConditionContext().getChildTrueSuccessor(this)
    )
  }

  override Instruction getChildFalseSuccessor(TranslatedCondition child) {
    (child = getLeftOperand() or child = getRightOperand()) and
    result = getConditionContext().getChildFalseSuccessor(this)
  }
}

class TranslatedLogicalOrExpr extends TranslatedBinaryLogicalOperation {
  TranslatedLogicalOrExpr() {
    op instanceof LogicalOrExpr
  }

  override Instruction getChildTrueSuccessor(TranslatedCondition child) {
    (child = getLeftOperand() or child = getRightOperand()) and
    result = getConditionContext().getChildTrueSuccessor(this)
  }

  override Instruction getChildFalseSuccessor(TranslatedCondition child) {
    (
      child = getLeftOperand() and
      result = getRightOperand().getFirstInstruction()
    ) or
    (
      child = getRightOperand() and
      result = getConditionContext().getChildFalseSuccessor(this)
    )
  }
}

class TranslatedValueCondition extends TranslatedCondition,
  TTranslatedValueCondition {
  TranslatedValueCondition() {
    this = TTranslatedValueCondition(expr)
  }

  override TranslatedElement getChild(int id) {
    id = 0 and result = getValueExpr()
  }

  override Instruction getFirstInstruction() {
    result = getValueExpr().getFirstInstruction()
  }

  override predicate hasInstruction(Opcode opcode, InstructionTag tag,
    Type resultType, boolean isGLValue) {
    tag = ValueConditionConditionalBranchTag() and
    opcode instanceof Opcode::ConditionalBranch and
    resultType instanceof VoidType and
    isGLValue = false
  }

  override Instruction getChildSuccessor(TranslatedElement child) {
    child = getValueExpr() and
    result = getInstruction(ValueConditionConditionalBranchTag())
  }

  override Instruction getInstructionSuccessor(InstructionTag tag,
    EdgeKind kind) {
    tag = ValueConditionConditionalBranchTag() and
    (
      (
        kind instanceof TrueEdge and
        result = getConditionContext().getChildTrueSuccessor(this)
      ) or
      (
        kind instanceof FalseEdge and
        result = getConditionContext().getChildFalseSuccessor(this)
      )
    )
  }

  override Instruction getInstructionOperand(InstructionTag tag,
    OperandTag operandTag) {
    tag = ValueConditionConditionalBranchTag() and
    operandTag instanceof ConditionOperand and
    result = getValueExpr().getResult()
  }

  private TranslatedExpr getValueExpr() {
    result = getTranslatedExpr(expr)
  }
}
