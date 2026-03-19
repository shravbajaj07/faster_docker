// Copyright (C) 2026, Gurobi Optimization, LLC
// All Rights Reserved
#ifndef _CPP_EXCEPTION_H_
#define _CPP_EXCEPTION_H_

#include <stdexcept>

class GRBException : public std::runtime_error
{
  private:

    int error;

  public:

    GRBException(int errcode = 0) : runtime_error(""), error(errcode) {}
    GRBException(const GRBException& exc) : runtime_error(exc), error(exc.error) {}
    GRBException(std::string errmsg, int errcode = 0) : runtime_error(errmsg), error(errcode) {}

    const std::string getMessage() const;
    int getErrorCode() const;
};
#endif
