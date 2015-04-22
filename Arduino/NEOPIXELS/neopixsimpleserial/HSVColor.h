/* 
 * These two classes represent colors in HSV format (which can be converted to RGB)
 * One class uses floating point numbers (HSVColorf) the other uses ints for speed (HSVColori)
 * Borrowed some code (most of toRGB) from the excellent toxiclibs - http://toxiclibs.org
 * Optimized (a bit) for C++ and the Arduino
 *
 * by Evan Raskob <evan@openlabworkshops.org>
 
 **********************************
 *  Copyright (C) 2011 Evan Raskob and the team at Openlab Workshops' Life Project:
 * <info@openlabworkshops.org> 
 * http://lifeproject.spacestudios.org.uk
 * http://openlabworkshops.org
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Affero General Public License for more details.
 
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 ***********************************
 */
#ifndef HSVColor_h
#define HSVColor_h


class HSVColori
{
public:

  int h;
  int s;
  int v;


  HSVColori(): 
  h(0), s(0), v(0)
  { 
  }

  HSVColori(int _h, int _s, int _v): 
  h(_h), s(_s), v(_v)
  { 
  }

  static const float INV_INV60DEGREES = 6.0/255.0; //  = 360 / 60

  void set(int _h, int _s, int _v)
  {
    h = _h;
    s = _s;
    v = _v;
  }

  HSVColori& shiftHue(int amt)
  {
    h = (h + amt) & 0xFF;
    
    return *this;
  }

  HSVColori& brighten(int amt)
  {
    v = (v + amt) & 0xFF;
    return *this;
  }

  HSVColori& saturate(int amt)
  {
    s = (s + amt) & 0xFF;
    return *this;    
  }

  // Convert a color in H,S,V to RGB
  static uint32_t toRGB(int _h, int _s, int _v) 
  {
    uint8_t r,g,b;
    float __h = _h, __s = _s, __v = _v;
    
    if (_s < 1)
    {
      r = g = b = _v;
    } 
    else 
    {
      /*
      Serial.print("h:");
    Serial.print(__h);
    Serial.print("s:");
    Serial.print(__s);
    Serial.print("v:");
    Serial.println(__v);
      */
      __s = __s/255.0;
      
      __h *= INV_INV60DEGREES;
      
      int i = (int)__h;
      //Serial.println(i);
      float f = __h - i;
      float p = __v * (1.0 - __s);
      float q = __v * (1.0 - __s * f);
      float t = __v * (1.0 - __s * (1 - f));

      if (i == 0) {
        r = __v;
        g = t;
        b = p;
      } 
      else if (i == 1) {
        r = q;
        g = __v;
        b = p;
      } 
      else if (i == 2) {
        r = p;
        g = __v;
        b = t;
      } 
      else if (i == 3) {
        r = p;
        g = q;
        b = __v;
      } 
      else if (i == 4) {
        r = t;
        g = p;
        b = __v;
      } 
      else {
        r = __v;
        g = p;
        b = q;
      }
    }
    /*
    Serial.print("r:");
    Serial.print(r);
    Serial.print("g:");
    Serial.print(g);
    Serial.print("b:");
    Serial.println(b);
    */
    
    return ((uint32_t)r << 16) | ((uint32_t)g <<  8) | (uint32_t)b;
    // end toRGB
  }



  // Convert THIS color to RGB
  uint32_t toRGB() 
  {
    return toRGB(h, s, v);
    // end toRGB
  }

  // 
  // transition between two colors smoothly (linear interpolation)
  //
  static void lerp(const HSVColori& first, const HSVColori& second, HSVColori& result, int amount)
  {
    int minus_amount = 255-amount;
    result.h = (first.h*minus_amount + second.h*amount) / 255;
    result.s = (first.s*minus_amount + second.s*amount) / 255;
    result.v = (first.v*minus_amount + second.v*amount) / 255;
  }

  // 
  // transition between THIS color and a second smoothly (linear interpolation)
  //
  void lerp(const HSVColori& second, HSVColori& result, int amount)
  {
    lerp( (*this), second, result, amount );
  }

  // 
  // transition between THIS color and a second smoothly (linear interpolation)
  //
  HSVColori& lerp(const HSVColori& second, int amount)
  {
    lerp( (*this), second, (*this), amount );
    return (*this);
  }

  HSVColori& operator=(const HSVColori& rhs) { 
    if (this != &rhs) 
    { 
      // check for self-assignment
      this->h = rhs.h;
      this->s = rhs.s;
      this->v = rhs.v;
    }
    return *this;
  }

  bool operator==(const HSVColori& rhs) {  
    if (this == &rhs) return true;

    return 
      (
    this->h == rhs.h &&
      this->s == rhs.s &&
      this->v == rhs.v 
      );
  }

  bool operator!=(const HSVColori& rhs) 
  {  
    return !(*this == rhs);
  }

  //end class HSVColori
};




#endif
