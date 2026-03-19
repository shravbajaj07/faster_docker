// Copyright (C) 2026, Gurobi Optimization, LLC
// All Rights Reserved
#include "Common.h"

const string
GRBException::getMessage() const
{
  return what();
}

int
GRBException::getErrorCode() const
{
  return error;
}
